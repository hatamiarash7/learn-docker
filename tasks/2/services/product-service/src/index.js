/**
 * ShopStream Product Service
 * ==========================
 * Handles product catalog management with Elasticsearch integration.
 */

const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");
const { Client } = require("@elastic/elasticsearch");

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================
// Configuration
// ============================================

const config = {
  db: {
    host: process.env.DB_HOST || "mariadb",
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || "appuser",
    password: process.env.DB_PASSWORD || "apppassword",
    database: process.env.DB_NAME || "shopstream",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  },
  elasticsearch: {
    node: process.env.ELASTICSEARCH_URL || "http://elasticsearch:9200",
    auth: process.env.ELASTICSEARCH_PASSWORD
      ? {
          username: "elastic",
          password: process.env.ELASTICSEARCH_PASSWORD,
        }
      : undefined,
  },
};

// ============================================
// Database Connection
// ============================================

let dbPool = null;

async function initDatabase() {
  try {
    dbPool = mysql.createPool(config.db);

    // Test connection
    const connection = await dbPool.getConnection();
    console.log("✓ Database connected");

    // Create tables
    await connection.execute(`
            CREATE TABLE IF NOT EXISTS products (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                price DECIMAL(10,2) NOT NULL,
                category VARCHAR(100) NOT NULL,
                image VARCHAR(500),
                stock INT NOT NULL DEFAULT 0,
                sku VARCHAR(50) UNIQUE,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_category (category),
                INDEX idx_active (is_active),
                FULLTEXT INDEX idx_search (name, description)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        `);

    // Insert sample products if empty
    const [rows] = await connection.execute(
      "SELECT COUNT(*) as count FROM products"
    );
    if (rows[0].count === 0) {
      await insertSampleProducts(connection);
    }

    connection.release();
    console.log("✓ Database tables initialized");
    return true;
  } catch (error) {
    console.error("✗ Database error:", error.message);
    return false;
  }
}

async function insertSampleProducts(connection) {
  const products = [
    {
      name: "Wireless Headphones",
      description:
        "Premium noise-cancelling wireless headphones with 30-hour battery life",
      price: 199.99,
      category: "Electronics",
      stock: 50,
      sku: "ELEC-001",
    },
    {
      name: "Smart Watch",
      description:
        "Fitness tracking smartwatch with heart rate monitor and GPS",
      price: 299.99,
      category: "Electronics",
      stock: 30,
      sku: "ELEC-002",
    },
    {
      name: "Laptop Stand",
      description: "Ergonomic aluminum laptop stand for better posture",
      price: 49.99,
      category: "Electronics",
      stock: 100,
      sku: "ELEC-003",
    },
    {
      name: "USB-C Hub",
      description: "7-in-1 USB-C hub with HDMI, USB 3.0, and SD card reader",
      price: 59.99,
      category: "Electronics",
      stock: 75,
      sku: "ELEC-004",
    },
    {
      name: "Mechanical Keyboard",
      description: "RGB mechanical keyboard with Cherry MX switches",
      price: 149.99,
      category: "Electronics",
      stock: 40,
      sku: "ELEC-005",
    },
    {
      name: "Running Shoes",
      description: "Lightweight running shoes with responsive cushioning",
      price: 129.99,
      category: "Sports",
      stock: 60,
      sku: "SPRT-001",
    },
    {
      name: "Yoga Mat",
      description: "Non-slip yoga mat with carrying strap",
      price: 34.99,
      category: "Sports",
      stock: 80,
      sku: "SPRT-002",
    },
    {
      name: "Dumbbell Set",
      description: "Adjustable dumbbell set 5-25 lbs",
      price: 199.99,
      category: "Sports",
      stock: 25,
      sku: "SPRT-003",
    },
    {
      name: "Coffee Maker",
      description: "Programmable 12-cup coffee maker with thermal carafe",
      price: 79.99,
      category: "Home",
      stock: 45,
      sku: "HOME-001",
    },
    {
      name: "Air Purifier",
      description: "HEPA air purifier for rooms up to 500 sq ft",
      price: 149.99,
      category: "Home",
      stock: 35,
      sku: "HOME-002",
    },
    {
      name: "Desk Lamp",
      description:
        "LED desk lamp with adjustable brightness and color temperature",
      price: 39.99,
      category: "Home",
      stock: 90,
      sku: "HOME-003",
    },
    {
      name: "Backpack",
      description: "Water-resistant laptop backpack with USB charging port",
      price: 59.99,
      category: "Accessories",
      stock: 70,
      sku: "ACCS-001",
    },
    {
      name: "Sunglasses",
      description: "Polarized sunglasses with UV400 protection",
      price: 89.99,
      category: "Accessories",
      stock: 55,
      sku: "ACCS-002",
    },
    {
      name: "Leather Wallet",
      description: "Genuine leather bifold wallet with RFID blocking",
      price: 44.99,
      category: "Accessories",
      stock: 65,
      sku: "ACCS-003",
    },
    {
      name: "Water Bottle",
      description: "Insulated stainless steel water bottle 32oz",
      price: 29.99,
      category: "Accessories",
      stock: 120,
      sku: "ACCS-004",
    },
  ];

  for (const product of products) {
    await connection.execute(
      `INSERT INTO products (name, description, price, category, stock, sku, image) 
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        product.name,
        product.description,
        product.price,
        product.category,
        product.stock,
        product.sku,
        `https://picsum.photos/seed/${product.sku}/300/200`,
      ]
    );
  }

  console.log(`✓ Inserted ${products.length} sample products`);
}

// ============================================
// Elasticsearch Connection
// ============================================

let esClient = null;
let esAvailable = false;

async function initElasticsearch() {
  try {
    esClient = new Client(config.elasticsearch);

    // Test connection
    await esClient.ping();
    console.log("✓ Elasticsearch connected");

    // Create index if not exists
    const indexExists = await esClient.indices.exists({ index: "products" });
    if (!indexExists) {
      await esClient.indices.create({
        index: "products",
        body: {
          mappings: {
            properties: {
              name: { type: "text", analyzer: "standard" },
              description: { type: "text", analyzer: "standard" },
              category: { type: "keyword" },
              price: { type: "float" },
              stock: { type: "integer" },
            },
          },
        },
      });
      console.log("✓ Elasticsearch index created");
    }

    esAvailable = true;
    return true;
  } catch (error) {
    console.warn("⚠ Elasticsearch not available:", error.message);
    esAvailable = false;
    return false;
  }
}

async function indexProduct(product) {
  if (!esAvailable) return;

  try {
    await esClient.index({
      index: "products",
      id: product.id.toString(),
      body: {
        name: product.name,
        description: product.description,
        category: product.category,
        price: product.price,
        stock: product.stock,
      },
    });
  } catch (error) {
    console.error("Elasticsearch indexing error:", error.message);
  }
}

// ============================================
// Middleware
// ============================================

app.use(cors());
app.use(express.json());

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// ============================================
// Health Check
// ============================================

app.get("/health", async (req, res) => {
  const health = {
    status: "healthy",
    service: "product-service",
    timestamp: new Date().toISOString(),
  };

  // Check database
  try {
    const connection = await dbPool.getConnection();
    await connection.execute("SELECT 1");
    connection.release();
    health.database = "connected";
  } catch (error) {
    health.database = "disconnected";
    health.status = "degraded";
  }

  // Check Elasticsearch
  if (esAvailable) {
    try {
      await esClient.ping();
      health.elasticsearch = "connected";
    } catch (error) {
      health.elasticsearch = "disconnected";
      health.status = "degraded";
    }
  } else {
    health.elasticsearch = "disabled";
  }

  const statusCode = health.status === "healthy" ? 200 : 503;
  res.status(statusCode).json(health);
});

// ============================================
// Product Routes
// ============================================

// Get all products
app.get("/products", async (req, res) => {
  try {
    const { category, minPrice, maxPrice, limit = 50, offset = 0 } = req.query;

    let query = "SELECT * FROM products WHERE is_active = TRUE";
    const params = [];

    if (category) {
      query += " AND category = ?";
      params.push(category);
    }

    if (minPrice) {
      query += " AND price >= ?";
      params.push(parseFloat(minPrice));
    }

    if (maxPrice) {
      query += " AND price <= ?";
      params.push(parseFloat(maxPrice));
    }

    query += " ORDER BY created_at DESC LIMIT ? OFFSET ?";
    params.push(parseInt(limit), parseInt(offset));

    const [products] = await dbPool.execute(query, params);

    res.json(products);
  } catch (error) {
    console.error("Get products error:", error);
    res.status(500).json({ error: "Failed to fetch products" });
  }
});

// Search products
app.get("/products/search", async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({ error: "Search query is required" });
    }

    // Try Elasticsearch first
    if (esAvailable) {
      try {
        const result = await esClient.search({
          index: "products",
          body: {
            query: {
              multi_match: {
                query: q,
                fields: ["name^2", "description", "category"],
                fuzziness: "AUTO",
              },
            },
          },
        });

        const ids = result.hits.hits.map((hit) => hit._id);

        if (ids.length > 0) {
          const [products] = await dbPool.execute(
            `SELECT * FROM products WHERE id IN (${ids.join(
              ","
            )}) AND is_active = TRUE`
          );
          return res.json(products);
        }

        return res.json([]);
      } catch (esError) {
        console.warn(
          "Elasticsearch search failed, using MySQL:",
          esError.message
        );
      }
    }

    // Fallback to MySQL fulltext search
    const [products] = await dbPool.execute(
      `SELECT * FROM products 
             WHERE is_active = TRUE AND MATCH(name, description) AGAINST(? IN NATURAL LANGUAGE MODE)
             LIMIT 50`,
      [q]
    );

    // If no results, try LIKE search
    if (products.length === 0) {
      const [likeProducts] = await dbPool.execute(
        `SELECT * FROM products 
                 WHERE is_active = TRUE AND (name LIKE ? OR description LIKE ? OR category LIKE ?)
                 LIMIT 50`,
        [`%${q}%`, `%${q}%`, `%${q}%`]
      );
      return res.json(likeProducts);
    }

    res.json(products);
  } catch (error) {
    console.error("Search error:", error);
    res.status(500).json({ error: "Search failed" });
  }
});

// Get single product
app.get("/products/:id", async (req, res) => {
  try {
    const [products] = await dbPool.execute(
      "SELECT * FROM products WHERE id = ? AND is_active = TRUE",
      [req.params.id]
    );

    if (products.length === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    res.json(products[0]);
  } catch (error) {
    console.error("Get product error:", error);
    res.status(500).json({ error: "Failed to fetch product" });
  }
});

// Get categories
app.get("/categories", async (req, res) => {
  try {
    const [categories] = await dbPool.execute(
      "SELECT DISTINCT category FROM products WHERE is_active = TRUE ORDER BY category"
    );

    res.json(categories.map((c) => c.category));
  } catch (error) {
    console.error("Get categories error:", error);
    res.status(500).json({ error: "Failed to fetch categories" });
  }
});

// Create product (requires auth - handled by API gateway)
app.post("/products", async (req, res) => {
  try {
    const { name, description, price, category, image, stock, sku } = req.body;

    if (!name || !price || !category) {
      return res
        .status(400)
        .json({ error: "Name, price, and category are required" });
    }

    const [result] = await dbPool.execute(
      `INSERT INTO products (name, description, price, category, image, stock, sku) 
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [name, description, price, category, image, stock || 0, sku]
    );

    const product = {
      id: result.insertId,
      name,
      description,
      price,
      category,
      image,
      stock: stock || 0,
      sku,
    };

    // Index in Elasticsearch
    await indexProduct(product);

    res.status(201).json(product);
  } catch (error) {
    console.error("Create product error:", error);

    if (error.code === "ER_DUP_ENTRY") {
      return res
        .status(409)
        .json({ error: "Product with this SKU already exists" });
    }

    res.status(500).json({ error: "Failed to create product" });
  }
});

// Update product
app.put("/products/:id", async (req, res) => {
  try {
    const { name, description, price, category, image, stock, sku, is_active } =
      req.body;

    const [result] = await dbPool.execute(
      `UPDATE products SET 
                name = COALESCE(?, name),
                description = COALESCE(?, description),
                price = COALESCE(?, price),
                category = COALESCE(?, category),
                image = COALESCE(?, image),
                stock = COALESCE(?, stock),
                sku = COALESCE(?, sku),
                is_active = COALESCE(?, is_active)
             WHERE id = ?`,
      [
        name,
        description,
        price,
        category,
        image,
        stock,
        sku,
        is_active,
        req.params.id,
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Get updated product
    const [products] = await dbPool.execute(
      "SELECT * FROM products WHERE id = ?",
      [req.params.id]
    );

    // Re-index in Elasticsearch
    await indexProduct(products[0]);

    res.json(products[0]);
  } catch (error) {
    console.error("Update product error:", error);
    res.status(500).json({ error: "Failed to update product" });
  }
});

// Delete product (soft delete)
app.delete("/products/:id", async (req, res) => {
  try {
    const [result] = await dbPool.execute(
      "UPDATE products SET is_active = FALSE WHERE id = ?",
      [req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Product not found" });
    }

    // Remove from Elasticsearch
    if (esAvailable) {
      try {
        await esClient.delete({
          index: "products",
          id: req.params.id.toString(),
        });
      } catch (error) {
        // Ignore if not found
      }
    }

    res.json({ message: "Product deleted" });
  } catch (error) {
    console.error("Delete product error:", error);
    res.status(500).json({ error: "Failed to delete product" });
  }
});

// Update stock (for order processing)
app.post("/products/:id/stock", async (req, res) => {
  try {
    const { quantity } = req.body;

    if (quantity === undefined) {
      return res.status(400).json({ error: "Quantity is required" });
    }

    const [result] = await dbPool.execute(
      "UPDATE products SET stock = stock + ? WHERE id = ? AND (stock + ?) >= 0",
      [quantity, req.params.id, quantity]
    );

    if (result.affectedRows === 0) {
      return res
        .status(400)
        .json({ error: "Insufficient stock or product not found" });
    }

    res.json({ message: "Stock updated" });
  } catch (error) {
    console.error("Update stock error:", error);
    res.status(500).json({ error: "Failed to update stock" });
  }
});

// ============================================
// Error Handling
// ============================================

app.use((err, req, res, next) => {
  console.error("Error:", err);
  res.status(500).json({ error: "Internal server error" });
});

app.use((req, res) => {
  res.status(404).json({ error: "Endpoint not found" });
});

// ============================================
// Startup
// ============================================

async function waitForDatabase(maxRetries = 30, interval = 2000) {
  for (let i = 0; i < maxRetries; i++) {
    if (await initDatabase()) {
      return true;
    }
    console.log(`Waiting for database... (${i + 1}/${maxRetries})`);
    await new Promise((resolve) => setTimeout(resolve, interval));
  }
  return false;
}

async function start() {
  console.log(`
╔═══════════════════════════════════════════════╗
║       ShopStream Product Service              ║
╠═══════════════════════════════════════════════╣
║  Port: ${PORT}                                   ║
║  Health: /health                              ║
╚═══════════════════════════════════════════════╝
    `);

  if (!(await waitForDatabase())) {
    console.error("Failed to connect to database");
    process.exit(1);
  }

  // Initialize Elasticsearch (non-blocking)
  initElasticsearch().then(async () => {
    if (esAvailable) {
      // Index existing products
      const [products] = await dbPool.execute(
        "SELECT * FROM products WHERE is_active = TRUE"
      );
      for (const product of products) {
        await indexProduct(product);
      }
      console.log(`✓ Indexed ${products.length} products in Elasticsearch`);
    }
  });

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`✓ Server listening on port ${PORT}`);
  });
}

start();
