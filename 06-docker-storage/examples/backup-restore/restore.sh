#!/bin/bash

# ============================================
# Docker Volume Restore Script
# ============================================
# This script restores a Docker volume from
# a previously created backup file.
# ============================================

# Configuration
BACKUP_FILE="${1:-}"
VOLUME_NAME="${2:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
print_usage() {
	echo "Usage: $0 <backup_file> <volume_name>"
	echo ""
	echo "Arguments:"
	echo "  backup_file   Path to the backup .tar.gz file"
	echo "  volume_name   Name for the restored volume"
	echo ""
	echo "Example:"
	echo "  $0 ./backups/mysql-data_20240101_120000.tar.gz mysql-data-restored"
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
if [ -z "$BACKUP_FILE" ] || [ -z "$VOLUME_NAME" ]; then
	print_error "Error: Both backup file and volume name are required"
	print_usage
	exit 1
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
	print_error "Error: Backup file '$BACKUP_FILE' does not exist"
	exit 1
fi

# Check if volume already exists
if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
	print_info "Warning: Volume '$VOLUME_NAME' already exists"
	read -p "Do you want to overwrite it? (y/N): " confirm
	if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
		print_info "Restore cancelled"
		exit 0
	fi
	# Remove existing volume
	docker volume rm "$VOLUME_NAME" 2>/dev/null
fi

print_info "Creating volume: $VOLUME_NAME"

# Create the volume
docker volume create "$VOLUME_NAME"

if [ $? -ne 0 ]; then
	print_error "Failed to create volume"
	exit 1
fi

print_info "Restoring data from: $BACKUP_FILE"

# Get absolute path of backup file
BACKUP_DIR=$(dirname "$(realpath "$BACKUP_FILE")")
BACKUP_NAME=$(basename "$BACKUP_FILE")

# Restore the backup
docker run --rm \
	-v "${VOLUME_NAME}":/target \
	-v "${BACKUP_DIR}":/backup:ro \
	alpine:3.18 \
	sh -c "cd /target && tar xzf /backup/${BACKUP_NAME}"

# Check if restore was successful
if [ $? -eq 0 ]; then
	print_success "Restore completed successfully!"
	print_success "Volume '$VOLUME_NAME' is ready to use"
	echo ""
	echo "To use this volume:"
	echo "  docker run -v ${VOLUME_NAME}:/data alpine ls /data"
else
	print_error "Restore failed!"
	docker volume rm "$VOLUME_NAME" 2>/dev/null
	exit 1
fi
