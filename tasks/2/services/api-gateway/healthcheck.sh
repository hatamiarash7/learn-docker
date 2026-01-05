#!/bin/sh
# Health check script for Node.js services
wget -q --spider http://localhost:${PORT:-3000}/health || exit 1
