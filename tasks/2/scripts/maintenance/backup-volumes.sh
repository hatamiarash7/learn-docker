#!/bin/bash
# ============================================
# ShopStream - Backup Volumes
# ============================================
# Backs up all Docker volumes to a backup directory.
#
# Usage: ./backup-volumes.sh [--output DIR]
#
# Options:
#   --output DIR   Output directory (default: ./backups)
# ============================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }
log_success() { echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $1${NC}"; }
log_error() { echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗ $1${NC}"; }
log_warning() { echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠ $1${NC}"; }
log_info() { echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] ℹ $1${NC}"; }

# ============================================
# Configuration
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
STACK_NAME="shopstream"

# Volumes to backup
VOLUMES=(
	"${STACK_NAME}_mariadb-data"
	"${STACK_NAME}_redis-data"
	"${STACK_NAME}_elasticsearch-data"
	"${STACK_NAME}_rabbitmq-data"
	"${STACK_NAME}_minio-data"
	"${STACK_NAME}_prometheus-data"
	"${STACK_NAME}_grafana-data"
	"${STACK_NAME}_loki-data"
)

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--output)
		BACKUP_DIR="$2"
		shift 2
		;;
	-h | --help)
		echo "Usage: $0 [--output DIR]"
		exit 0
		;;
	*)
		log_error "Unknown option: $1"
		exit 1
		;;
	esac
done

# ============================================
# Backup Functions
# ============================================

backup_volume() {
	local volume=$1
	local backup_file="$BACKUP_DIR/${volume}_${TIMESTAMP}.tar.gz"

	# Check if volume exists
	if ! docker volume ls -q | grep -q "^${volume}$"; then
		log_warning "Volume '$volume' not found, skipping"
		return 0
	fi

	log_info "Backing up: $volume"

	# Create backup using a temporary container
	docker run --rm \
		-v "$volume:/source:ro" \
		-v "$BACKUP_DIR:/backup" \
		alpine:3.18 \
		tar czf "/backup/$(basename "$backup_file")" -C /source .

	if [ -f "$backup_file" ]; then
		local size
		size=$(du -h "$backup_file" | cut -f1)
		log_success "Backed up: $volume ($size)"
	else
		log_error "Failed to backup: $volume"
		return 1
	fi
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Volume Backup"
	echo "============================================"
	echo ""

	# Create backup directory
	mkdir -p "$BACKUP_DIR"

	log_info "Backup directory: $BACKUP_DIR"
	log_info "Timestamp: $TIMESTAMP"
	echo ""

	local backed_up=0
	local failed=0
	local skipped=0

	for volume in "${VOLUMES[@]}"; do
		if backup_volume "$volume"; then
			((backed_up++))
		else
			((failed++))
		fi
	done

	echo ""
	echo "============================================"
	echo "Backup Summary"
	echo "============================================"
	echo ""
	echo -e "Backed up: ${GREEN}$backed_up${NC}"
	echo -e "Failed:    ${RED}$failed${NC}"
	echo ""

	# List backup files
	echo "Backup files:"
	ls -lh "$BACKUP_DIR"/*_${TIMESTAMP}.tar.gz 2>/dev/null || echo "  No files created"
	echo ""

	# Show total size
	local total_size
	total_size=$(du -sh "$BACKUP_DIR" | cut -f1)
	log_info "Total backup directory size: $total_size"

	echo ""
	log_success "Backup complete!"
	echo ""
}

main "$@"
