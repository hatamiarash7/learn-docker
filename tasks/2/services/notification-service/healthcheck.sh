#!/bin/sh
# Health check script for Notification Service
wget -q --spider http://localhost:${PORT:-3000}/health || exit 1
