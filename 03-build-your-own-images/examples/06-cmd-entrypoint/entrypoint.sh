#!/bin/sh
# ===========================================
# Entrypoint Wrapper Script
# ===========================================
# This script runs before the main command.
# Use it for:
# - Environment setup
# - Waiting for dependencies
# - Configuration generation
# - Secret management
# - Database migrations
# ===========================================

echo "========================================"
echo "🚀 Container Starting"
echo "========================================"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "User: $(whoami)"
echo "========================================"

# Example: Wait for a database (commented out)
# echo "Waiting for database..."
# while ! nc -z db 5432; do
#     sleep 1
# done
# echo "Database is ready!"

# Example: Generate config from environment
# if [ -n "$CONFIG_TEMPLATE" ]; then
#     envsubst < /app/config.template > /app/config.json
# fi

echo "Executing command: $@"
echo "========================================"

# Execute the CMD (passed as arguments to this script)
# Using exec replaces this shell with the actual process
# This ensures signals (like SIGTERM) are passed correctly
exec "$@"
