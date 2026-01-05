#!/bin/sh
# Health check script for auth service

set -e

# Check if the service responds to health endpoint
curl -sf http://localhost:5000/health >/dev/null || exit 1

exit 0
