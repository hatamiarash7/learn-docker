/**
 * Simple Express Server for Docker Learning
 */

const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;
const APP_NAME = process.env.APP_NAME || "Docker Node App";

// Middleware to parse JSON
app.use(express.json());

// Home page
app.get("/", (req, res) => {
  res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>${APP_NAME}</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    max-width: 800px;
                    margin: 50px auto;
                    padding: 20px;
                    background: #f5f5f5;
                }
                .container {
                    background: white;
                    padding: 30px;
                    border-radius: 10px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
                h1 { color: #68a063; }
                code {
                    background: #e9ecef;
                    padding: 2px 8px;
                    border-radius: 4px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🐳 ${APP_NAME}</h1>
                <p>Welcome! This Node.js app is running inside a Docker container.</p>
                <h2>Available Endpoints:</h2>
                <ul>
                    <li><code>GET /</code> - This page</li>
                    <li><code>GET /health</code> - Health check</li>
                    <li><code>GET /api/status</code> - API status (JSON)</li>
                </ul>
                <h2>Environment:</h2>
                <ul>
                    <li>Node.js: ${process.version}</li>
                    <li>Port: ${PORT}</li>
                    <li>Environment: ${
                      process.env.NODE_ENV || "development"
                    }</li>
                </ul>
            </div>
        </body>
        </html>
    `);
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
  });
});

// API status endpoint
app.get("/api/status", (req, res) => {
  res.json({
    app_name: APP_NAME,
    node_version: process.version,
    environment: process.env.NODE_ENV || "development",
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  });
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
