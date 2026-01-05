/**
 * ShopStream Notification Service
 * ================================
 * Handles real-time notifications via WebSocket and processes
 * notification messages from RabbitMQ.
 */

const express = require("express");
const { createServer } = require("http");
const { WebSocketServer, WebSocket } = require("ws");
const cors = require("cors");
const amqp = require("amqplib");

const app = express();
const server = createServer(app);
const wss = new WebSocketServer({ server, path: "/ws" });

const PORT = process.env.PORT || 3000;

// ============================================
// Configuration
// ============================================

const config = {
  rabbitmq: {
    url: `amqp://${process.env.RABBITMQ_USER || "guest"}:${
      process.env.RABBITMQ_PASSWORD || "guest"
    }@${process.env.RABBITMQ_HOST || "rabbitmq"}:${
      process.env.RABBITMQ_PORT || 5672
    }`,
  },
};

// ============================================
// WebSocket Management
// ============================================

// Map of userId -> Set of WebSocket connections
const userConnections = new Map();

// Ping interval to keep connections alive
const PING_INTERVAL = 30000;

wss.on("connection", (ws, req) => {
  console.log("New WebSocket connection");

  let userId = null;
  let isAlive = true;

  // Handle pong responses
  ws.on("pong", () => {
    isAlive = true;
  });

  // Handle incoming messages
  ws.on("message", (data) => {
    try {
      const message = JSON.parse(data.toString());

      // Handle authentication
      if (message.type === "auth" && message.userId) {
        userId = message.userId.toString();

        // Add to user connections
        if (!userConnections.has(userId)) {
          userConnections.set(userId, new Set());
        }
        userConnections.get(userId).add(ws);

        console.log(`User ${userId} authenticated`);

        // Send confirmation
        ws.send(
          JSON.stringify({
            type: "auth_success",
            message: "Connected to notification service",
          })
        );
      }
    } catch (error) {
      console.error("Failed to parse WebSocket message:", error);
    }
  });

  // Handle connection close
  ws.on("close", () => {
    console.log("WebSocket connection closed");

    if (userId && userConnections.has(userId)) {
      userConnections.get(userId).delete(ws);

      // Clean up empty sets
      if (userConnections.get(userId).size === 0) {
        userConnections.delete(userId);
      }
    }
  });

  // Handle errors
  ws.on("error", (error) => {
    console.error("WebSocket error:", error);
  });

  // Send welcome message
  ws.send(
    JSON.stringify({
      type: "connected",
      message: "Welcome to ShopStream notifications",
      timestamp: new Date().toISOString(),
    })
  );
});

// Ping all clients periodically to detect dead connections
setInterval(() => {
  wss.clients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.ping();
    }
  });
}, PING_INTERVAL);

// ============================================
// Send Notification Functions
// ============================================

function sendToUser(userId, message) {
  const connections = userConnections.get(userId.toString());

  if (!connections || connections.size === 0) {
    console.log(`No active connections for user ${userId}`);
    return false;
  }

  const payload = JSON.stringify(message);
  let sent = 0;

  connections.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(payload);
      sent++;
    }
  });

  console.log(`Sent notification to ${sent} connections for user ${userId}`);
  return sent > 0;
}

function broadcast(message) {
  const payload = JSON.stringify(message);
  let sent = 0;

  wss.clients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(payload);
      sent++;
    }
  });

  console.log(`Broadcast notification to ${sent} connections`);
  return sent;
}

// ============================================
// RabbitMQ Consumer
// ============================================

let rabbitConnection = null;
let rabbitChannel = null;

async function connectRabbitMQ() {
  try {
    rabbitConnection = await amqp.connect(config.rabbitmq.url);
    rabbitChannel = await rabbitConnection.createChannel();

    // Declare queue
    await rabbitChannel.assertQueue("order_notifications", { durable: true });

    console.log("✓ RabbitMQ connected");

    // Start consuming
    rabbitChannel.consume("order_notifications", (msg) => {
      if (msg) {
        try {
          const content = JSON.parse(msg.content.toString());
          console.log("Received notification:", content);

          // Process notification
          processNotification(content);

          // Acknowledge message
          rabbitChannel.ack(msg);
        } catch (error) {
          console.error("Failed to process notification:", error);
          // Reject message, don't requeue
          rabbitChannel.nack(msg, false, false);
        }
      }
    });

    // Handle connection errors
    rabbitConnection.on("error", (error) => {
      console.error("RabbitMQ connection error:", error);
      setTimeout(connectRabbitMQ, 5000);
    });

    rabbitConnection.on("close", () => {
      console.log("RabbitMQ connection closed, reconnecting...");
      setTimeout(connectRabbitMQ, 5000);
    });

    return true;
  } catch (error) {
    console.error("Failed to connect to RabbitMQ:", error.message);
    setTimeout(connectRabbitMQ, 5000);
    return false;
  }
}

function processNotification(notification) {
  const { type, userId, ...data } = notification;

  const message = {
    type,
    ...data,
    timestamp: new Date().toISOString(),
  };

  switch (type) {
    case "order_created":
      message.title = "Order Placed!";
      message.body = `Your order #${data.orderId} has been placed successfully.`;
      break;

    case "order_update":
      message.title = "Order Update";
      message.body = `Your order #${data.orderId} status: ${data.status}`;
      break;

    case "order_cancelled":
      message.title = "Order Cancelled";
      message.body = `Your order #${data.orderId} has been cancelled.`;
      break;

    case "promotion":
      // Broadcast promotions to all users
      broadcast(message);
      return;

    default:
      console.log("Unknown notification type:", type);
  }

  if (userId) {
    sendToUser(userId, message);
  }
}

// ============================================
// HTTP Routes
// ============================================

app.use(cors());
app.use(express.json());

// Health check
app.get("/health", (req, res) => {
  const health = {
    status: "healthy",
    service: "notification-service",
    timestamp: new Date().toISOString(),
    websocket: {
      connections: wss.clients.size,
      users: userConnections.size,
    },
  };

  // Check RabbitMQ
  if (rabbitConnection && rabbitChannel) {
    health.rabbitmq = "connected";
  } else {
    health.rabbitmq = "disconnected";
    health.status = "degraded";
  }

  const statusCode = health.status === "healthy" ? 200 : 503;
  res.status(statusCode).json(health);
});

// Send notification via HTTP (internal API)
app.post("/notify", (req, res) => {
  const { userId, type, data } = req.body;

  if (!type) {
    return res.status(400).json({ error: "Notification type is required" });
  }

  const message = {
    type,
    ...data,
    timestamp: new Date().toISOString(),
  };

  if (userId) {
    const sent = sendToUser(userId, message);
    res.json({
      success: sent,
      message: sent ? "Notification sent" : "User not connected",
    });
  } else {
    const count = broadcast(message);
    res.json({ success: true, recipients: count });
  }
});

// Send broadcast notification
app.post("/broadcast", (req, res) => {
  const { message, type = "announcement" } = req.body;

  if (!message) {
    return res.status(400).json({ error: "Message is required" });
  }

  const count = broadcast({
    type,
    message,
    timestamp: new Date().toISOString(),
  });

  res.json({ success: true, recipients: count });
});

// Get connection stats
app.get("/stats", (req, res) => {
  const stats = {
    totalConnections: wss.clients.size,
    authenticatedUsers: userConnections.size,
    connectionsByUser: {},
  };

  userConnections.forEach((connections, userId) => {
    stats.connectionsByUser[userId] = connections.size;
  });

  res.json(stats);
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
// Graceful Shutdown
// ============================================

async function shutdown() {
  console.log("\nShutting down gracefully...");

  // Close WebSocket connections
  wss.clients.forEach((ws) => {
    ws.close(1000, "Server shutting down");
  });

  // Close RabbitMQ
  if (rabbitChannel) {
    await rabbitChannel.close();
  }
  if (rabbitConnection) {
    await rabbitConnection.close();
  }

  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
}

process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);

// ============================================
// Start Server
// ============================================

server.listen(PORT, "0.0.0.0", () => {
  console.log(`
╔═══════════════════════════════════════════════╗
║     ShopStream Notification Service           ║
╠═══════════════════════════════════════════════╣
║  HTTP Port: ${PORT}                              ║
║  WebSocket: /ws                               ║
║  Health: /health                              ║
╚═══════════════════════════════════════════════╝
    `);

  // Connect to RabbitMQ
  connectRabbitMQ();
});
