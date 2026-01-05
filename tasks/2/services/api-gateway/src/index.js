/**
 * ShopStream API Gateway
 * ======================
 * Central entry point for all API requests.
 * Handles routing, rate limiting, authentication validation, and request logging.
 */

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");
const { createProxyMiddleware } = require("http-proxy-middleware");
const jwt = require("jsonwebtoken");
const Redis = require("ioredis");

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================
// Configuration
// ============================================

const config = {
  jwtSecret: process.env.JWT_SECRET || "development-secret-key",
  redis: {
    host: process.env.REDIS_HOST || "redis",
    port: process.env.REDIS_PORT || 6379,
    password: process.env.REDIS_PASSWORD || "",
  },
  services: {
    auth: process.env.AUTH_SERVICE_URL || "http://auth-service:5000",
    product: process.env.PRODUCT_SERVICE_URL || "http://product-service:3000",
    order: process.env.ORDER_SERVICE_URL || "http://order-service:5000",
    notification:
      process.env.NOTIFICATION_SERVICE_URL ||
      "http://notification-service:3000",
  },
};

// ============================================
// Redis Connection
// ============================================

const redis = new Redis({
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password,
  retryDelayOnFailover: 100,
  maxRetriesPerRequest: 3,
  lazyConnect: true,
});

redis.on("connect", () => console.log("✓ Redis connected"));
redis.on("error", (err) => console.error("✗ Redis error:", err.message));

// ============================================
// Middleware
// ============================================

// Security headers
app.use(
  helmet({
    contentSecurityPolicy: false, // Allow inline scripts for development
  })
);

// CORS
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
    credentials: true,
  })
);

// Request logging
app.use(
  morgan(":method :url :status :response-time ms - :res[content-length]")
);

// Body parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// ============================================
// Rate Limiting
// ============================================

// General rate limiter
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: { error: "Too many requests, please try again later" },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => req.path === "/health",
});

// Strict limiter for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10, // 10 auth attempts per 15 minutes
  message: { error: "Too many authentication attempts" },
});

app.use(generalLimiter);

// ============================================
// Authentication Middleware
// ============================================

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ error: "Authentication required" });
  }

  try {
    // Check if token is blacklisted (logged out)
    const isBlacklisted = await redis.get(`blacklist:${token}`);
    if (isBlacklisted) {
      return res.status(401).json({ error: "Token has been revoked" });
    }

    const decoded = jwt.verify(token, config.jwtSecret);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: "Invalid or expired token" });
  }
};

// Optional auth - doesn't fail if no token
const optionalAuth = async (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token) {
    try {
      const isBlacklisted = await redis.get(`blacklist:${token}`);
      if (!isBlacklisted) {
        req.user = jwt.verify(token, config.jwtSecret);
      }
    } catch (error) {
      // Token invalid, but continue without auth
    }
  }
  next();
};

// ============================================
// Health Check
// ============================================

app.get("/health", async (req, res) => {
  const health = {
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    services: {},
  };

  // Check Redis
  try {
    await redis.ping();
    health.cache = "connected";
  } catch (error) {
    health.cache = "disconnected";
    health.status = "degraded";
  }

  // Check downstream services
  const serviceChecks = Object.entries(config.services).map(
    async ([name, url]) => {
      try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 2000);

        const response = await fetch(`${url}/health`, {
          signal: controller.signal,
        });
        clearTimeout(timeout);

        health.services[name] = response.ok ? "healthy" : "unhealthy";
      } catch (error) {
        health.services[name] = "unreachable";
        health.status = "degraded";
      }
    }
  );

  await Promise.all(serviceChecks);

  // Also add database status from auth service
  try {
    const authHealth = await fetch(`${config.services.auth}/health`);
    const authData = await authHealth.json();
    health.database = authData.database || "unknown";
  } catch (error) {
    health.database = "unknown";
  }

  const statusCode = health.status === "healthy" ? 200 : 503;
  res.status(statusCode).json(health);
});

// ============================================
// Metrics Endpoint (for Prometheus)
// ============================================

let requestCount = 0;
let errorCount = 0;

app.use((req, res, next) => {
  requestCount++;
  res.on("finish", () => {
    if (res.statusCode >= 400) errorCount++;
  });
  next();
});

app.get("/metrics", (req, res) => {
  res.set("Content-Type", "text/plain");
  res.send(
    `
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total ${requestCount}

# HELP http_errors_total Total HTTP errors
# TYPE http_errors_total counter
http_errors_total ${errorCount}

# HELP nodejs_heap_size_bytes Node.js heap size
# TYPE nodejs_heap_size_bytes gauge
nodejs_heap_size_bytes ${process.memoryUsage().heapUsed}

# HELP process_uptime_seconds Process uptime
# TYPE process_uptime_seconds gauge
process_uptime_seconds ${process.uptime()}
    `.trim()
  );
});

// ============================================
// API Routes - Auth Service
// ============================================

app.use("/auth", authLimiter);

// Proxy to auth service
app.post(
  "/auth/register",
  createProxyMiddleware({
    target: config.services.auth,
    changeOrigin: true,
    pathRewrite: { "^/auth": "" },
  })
);

app.post(
  "/auth/login",
  createProxyMiddleware({
    target: config.services.auth,
    changeOrigin: true,
    pathRewrite: { "^/auth": "" },
  })
);

app.get("/auth/me", authenticateToken, (req, res) => {
  res.json(req.user);
});

app.post("/auth/logout", authenticateToken, async (req, res) => {
  const token = req.headers["authorization"].split(" ")[1];

  // Blacklist the token
  const decoded = jwt.decode(token);
  const ttl = decoded.exp - Math.floor(Date.now() / 1000);

  if (ttl > 0) {
    await redis.setex(`blacklist:${token}`, ttl, "1");
  }

  res.json({ message: "Logged out successfully" });
});

// ============================================
// API Routes - Product Service
// ============================================

app.get(
  "/products",
  optionalAuth,
  createProxyMiddleware({
    target: config.services.product,
    changeOrigin: true,
  })
);

app.get(
  "/products/search",
  createProxyMiddleware({
    target: config.services.product,
    changeOrigin: true,
  })
);

app.get(
  "/products/:id",
  createProxyMiddleware({
    target: config.services.product,
    changeOrigin: true,
  })
);

// Admin routes (require auth)
app.post(
  "/products",
  authenticateToken,
  createProxyMiddleware({
    target: config.services.product,
    changeOrigin: true,
  })
);

app.put(
  "/products/:id",
  authenticateToken,
  createProxyMiddleware({
    target: config.services.product,
    changeOrigin: true,
  })
);

app.delete(
  "/products/:id",
  authenticateToken,
  createProxyMiddleware({
    target: config.services.product,
    changeOrigin: true,
  })
);

// ============================================
// API Routes - Cart (Redis-based)
// ============================================

app.get("/cart", authenticateToken, async (req, res) => {
  try {
    const cartKey = `cart:${req.user.id}`;
    const cartData = await redis.get(cartKey);
    res.json(cartData ? JSON.parse(cartData) : []);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch cart" });
  }
});

app.post("/cart/add", authenticateToken, async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    const cartKey = `cart:${req.user.id}`;

    let cart = [];
    const cartData = await redis.get(cartKey);
    if (cartData) {
      cart = JSON.parse(cartData);
    }

    const existingItem = cart.find((item) => item.productId === productId);
    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      // Fetch product details
      const productResponse = await fetch(
        `${config.services.product}/products/${productId}`
      );
      if (!productResponse.ok) {
        return res.status(404).json({ error: "Product not found" });
      }
      const product = await productResponse.json();

      cart.push({
        productId,
        name: product.name,
        price: product.price,
        image: product.image,
        quantity,
      });
    }

    await redis.setex(cartKey, 86400 * 7, JSON.stringify(cart)); // 7 days TTL
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: "Failed to add to cart" });
  }
});

app.post("/cart/sync", authenticateToken, async (req, res) => {
  try {
    const { items } = req.body;
    const cartKey = `cart:${req.user.id}`;

    let cart = [];
    const cartData = await redis.get(cartKey);
    if (cartData) {
      cart = JSON.parse(cartData);
    }

    // Merge items
    for (const item of items) {
      const existing = cart.find((c) => c.productId === item.productId);
      if (existing) {
        existing.quantity = Math.max(existing.quantity, item.quantity);
      } else {
        cart.push(item);
      }
    }

    await redis.setex(cartKey, 86400 * 7, JSON.stringify(cart));
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: "Failed to sync cart" });
  }
});

app.delete("/cart", authenticateToken, async (req, res) => {
  try {
    const cartKey = `cart:${req.user.id}`;
    await redis.del(cartKey);
    res.json({ message: "Cart cleared" });
  } catch (error) {
    res.status(500).json({ error: "Failed to clear cart" });
  }
});

// ============================================
// API Routes - Order Service
// ============================================

app.get(
  "/orders",
  authenticateToken,
  async (req, res, next) => {
    // Add user ID to headers for downstream service
    req.headers["x-user-id"] = req.user.id;
    next();
  },
  createProxyMiddleware({
    target: config.services.order,
    changeOrigin: true,
    onProxyReq: (proxyReq, req) => {
      proxyReq.setHeader("X-User-Id", req.user.id);
    },
  })
);

app.post("/orders", authenticateToken, async (req, res) => {
  try {
    // Get cart from Redis
    const cartKey = `cart:${req.user.id}`;
    const cartData = await redis.get(cartKey);

    if (!cartData) {
      return res.status(400).json({ error: "Cart is empty" });
    }

    const cart = JSON.parse(cartData);

    // Create order via order service
    const orderResponse = await fetch(`${config.services.order}/orders`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-User-Id": req.user.id,
      },
      body: JSON.stringify({
        userId: req.user.id,
        items: cart,
        total: cart.reduce((sum, item) => sum + item.price * item.quantity, 0),
      }),
    });

    if (!orderResponse.ok) {
      const error = await orderResponse.json();
      return res.status(orderResponse.status).json(error);
    }

    const order = await orderResponse.json();

    // Clear cart after successful order
    await redis.del(cartKey);

    // Notify user via notification service
    try {
      await fetch(`${config.services.notification}/notify`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          userId: req.user.id,
          type: "order_created",
          data: { orderId: order.id, total: order.total },
        }),
      });
    } catch (error) {
      console.error("Failed to send notification:", error.message);
    }

    res.status(201).json(order);
  } catch (error) {
    console.error("Order creation error:", error);
    res.status(500).json({ error: "Failed to create order" });
  }
});

app.post("/orders/:id/cancel", authenticateToken, async (req, res) => {
  try {
    const response = await fetch(
      `${config.services.order}/orders/${req.params.id}/cancel`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-User-Id": req.user.id,
        },
      }
    );

    const data = await response.json();
    res.status(response.status).json(data);
  } catch (error) {
    res.status(500).json({ error: "Failed to cancel order" });
  }
});

// ============================================
// Error Handling
// ============================================

app.use((err, req, res, next) => {
  console.error("Error:", err);
  res.status(500).json({
    error: "Internal server error",
    message: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Not found" });
});

// ============================================
// Graceful Shutdown
// ============================================

const shutdown = async () => {
  console.log("\nShutting down gracefully...");

  try {
    await redis.quit();
    console.log("Redis connection closed");
  } catch (error) {
    console.error("Error closing Redis:", error);
  }

  process.exit(0);
};

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);

// ============================================
// Start Server
// ============================================

const startServer = async () => {
  try {
    await redis.connect();
  } catch (error) {
    console.warn("Redis not available, starting without cache");
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`
╔═══════════════════════════════════════════════╗
║         ShopStream API Gateway                ║
╠═══════════════════════════════════════════════╣
║  Port: ${PORT}                                   ║
║  Health: /health                              ║
║  Metrics: /metrics                            ║
╚═══════════════════════════════════════════════╝
        `);
  });
};

startServer();
