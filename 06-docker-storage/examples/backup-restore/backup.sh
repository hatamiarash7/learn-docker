#!/bin/bash

# ============================================
# Docker Volume Backup Script
# ============================================
# This script creates a timestamped backup of
# a Docker volume to a specified directory.
# ============================================

# Configuration
VOLUME_NAME="${1:-}"
BACKUP_DIR="${2:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_usage() {
	echo "Usage: $0 <volume_name> [backup_directory]"
	echo ""
	echo "Arguments:"
	echo "  volume_name       Name of the Docker volume to backup"
	echo "  backup_directory  Directory to store backups (default: ./backups)"
	echo ""
	echo "Example:"
	echo "  $0 mysql-data /path/to/backups"
}

print_success() {
	echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
	echo -e "${RED}✗ $1${NC}"
}

print_info() {
	echo -e "${YELLOW}ℹ $1${NC}"
}

# Validate input
if [ -z "$VOLUME_NAME" ]; then
	print_error "Error: Volume name is required"
	print_usage
	exit 1
fi

# Check if volume exists
if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
	print_error "Error: Volume '$VOLUME_NAME' does not exist"
	echo ""
	echo "Available volumes:"
	docker volume ls --format "  - {{.Name}}"
	exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Generate backup filename
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

print_info "Starting backup of volume: $VOLUME_NAME"
print_info "Backup file: $BACKUP_FILE"

# Create the backup
docker run --rm \
	-v "${VOLUME_NAME}":/source:ro \
	-v "$(realpath "$BACKUP_DIR")":/backup \
	alpine:3.18 \
	tar czf "/backup/${VOLUME_NAME}_${TIMESTAMP}.tar.gz" -C /source .

# Check if backup was successful
if [ $? -eq 0 ]; then
	BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
	print_success "Backup completed successfully!"
	print_success "File: $BACKUP_FILE"
	print_success "Size: $BACKUP_SIZE"
else
	print_error "Backup failed!"
	exit 1
fi

# Optional: Clean up old backups (keep last 5)
BACKUP_COUNT=$(ls -1 "${BACKUP_DIR}/${VOLUME_NAME}_"*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 5 ]; then
	print_info "Cleaning up old backups (keeping last 5)..."
	ls -1t "${BACKUP_DIR}/${VOLUME_NAME}_"*.tar.gz | tail -n +6 | xargs rm -f
	print_success "Old backups removed"
fi

echo ""
echo "To restore this backup, run:"
echo "  ./restore.sh $BACKUP_FILE <new_volume_name>"
