#!/bin/sh
# Health check script for Product Service
wget -q --spider http://localhost:${PORT:-3000}/health || exit 1
