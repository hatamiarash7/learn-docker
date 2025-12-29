/**
 * Full Stack API Server
 * Demonstrates Node.js with MariaDB and Redis
 */

const express = require("express");
const mysql = require("mysql2/promise");
const redis = require("redis");

const app = express();
app.use(express.json());

// Configuration from environment
const config = {
  db: {
    host: process.env.DB_HOST || "localhost",
    port: process.env.DB_PORT || 3306,
    database: process.env.DB_NAME || "fullstack",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
  },
  redis: {
    host: process.env.REDIS_HOST || "localhost",
    port: process.env.REDIS_PORT || 6379,
  },
};

// Database connection pool
let dbPool;
let redisClient;

// Initialize connections
async function initConnections() {
  // MySQL connection pool
  dbPool = mysql.createPool({
    host: config.db.host,
    port: config.db.port,
    database: config.db.database,
    user: config.db.user,
    password: config.db.password,
    waitForConnections: true,
    connectionLimit: 10,
  });

  // Redis client
  redisClient = redis.createClient({
    socket: {
      host: config.redis.host,
      port: config.redis.port,
    },
  });

  redisClient.on("error", (err) => console.log("Redis Error:", err));
  await redisClient.connect();

  console.log("✓ Database and Redis connected");
}

// Routes

// Health check
app.get("/health", async (req, res) => {
  try {
    // Check database
    await dbPool.query("SELECT 1");
    // Check Redis
    await redisClient.ping();

    res.json({
      status: "healthy",
      database: "connected",
      cache: "connected",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      status: "unhealthy",
      error: error.message,
    });
  }
});

// Get all users
app.get("/users", async (req, res) => {
  try {
    const [rows] = await dbPool.query("SELECT * FROM users");
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create user
app.post("/users", async (req, res) => {
  try {
    const { username, email } = req.body;
    const [result] = await dbPool.query(
      "INSERT INTO users (username, email) VALUES (?, ?)",
      [username, email]
    );

    // Increment user count in Redis
    await redisClient.incr("stats:users");

    res.status(201).json({
      id: result.insertId,
      username,
      email,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get stats (with Redis caching)
app.get("/stats", async (req, res) => {
  try {
    // Try to get from cache
    let stats = await redisClient.get("stats:full");

    if (stats) {
      return res.json({
        ...JSON.parse(stats),
        source: "cache",
      });
    }

    // Get from database
    const [userCount] = await dbPool.query(
      "SELECT COUNT(*) as count FROM users"
    );
    const [postCount] = await dbPool.query(
      "SELECT COUNT(*) as count FROM posts"
    );

    stats = {
      users: userCount[0].count,
      posts: postCount[0].count,
      timestamp: new Date().toISOString(),
    };

    // Cache for 60 seconds
    await redisClient.setEx("stats:full", 60, JSON.stringify(stats));

    res.json({
      ...stats,
      source: "database",
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// API info
app.get("/", (req, res) => {
  res.json({
    name: "Full Stack API",
    version: "1.0.0",
    endpoints: [
      "GET /health - Health check",
      "GET /users - List users",
      "POST /users - Create user",
      "GET /stats - Get statistics (cached)",
    ],
  });
});

// Start server
const PORT = process.env.PORT || 3000;

initConnections()
  .then(() => {
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`🚀 API server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Failed to initialize:", err);
    process.exit(1);
  });
