#!/bin/bash
# ============================================
# ShopStream - Deploy Stack
# ============================================
# Deploys the complete ShopStream stack to Docker Swarm.
#
# Usage: ./deploy-stack.sh [--build] [--force]
#
# Options:
#   --build     Build images before deploying
#   --force     Force update all services
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

STACK_NAME="shopstream"
BUILD_FIRST=false
FORCE_UPDATE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--build)
		BUILD_FIRST=true
		shift
		;;
	--force)
		FORCE_UPDATE=true
		shift
		;;
	-h | --help)
		echo "Usage: $0 [--build] [--force]"
		exit 0
		;;
	*)
		log_error "Unknown option: $1"
		exit 1
		;;
	esac
done

# ============================================
# Pre-flight Checks
# ============================================

check_swarm() {
	if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
		log_error "This node is not a swarm manager"
		log_info "Run ./scripts/cluster/init-swarm.sh first"
		exit 1
	fi

	local nodes
	nodes=$(docker node ls -q | wc -l)
	log_success "Swarm active with $nodes node(s)"
}

check_secrets() {
	local required_secrets=(
		"db_root_password"
		"db_password"
		"redis_password"
		"jwt_secret"
		"rabbitmq_password"
	)

	local missing=0

	for secret in "${required_secrets[@]}"; do
		if ! docker secret ls --format '{{.Name}}' | grep -q "^${secret}$"; then
			log_error "Missing secret: $secret"
			((missing++))
		fi
	done

	if [ $missing -gt 0 ]; then
		log_error "Missing $missing required secrets"
		log_info "Run ./scripts/secrets/create-secrets.sh first"
		exit 1
	fi

	log_success "All required secrets exist"
}

check_stack_file() {
	if [ ! -f "$PROJECT_ROOT/docker-stack.yml" ]; then
		log_error "Stack file not found: $PROJECT_ROOT/docker-stack.yml"
		log_info "Create your docker-stack.yml file first"
		exit 1
	fi

	log_success "Stack file found"
}

check_networks() {
	local networks=("traefik-public" "frontend" "backend" "data" "monitoring")

	for network in "${networks[@]}"; do
		if ! docker network ls --format '{{.Name}}' | grep -q "^${network}$"; then
			log_warning "Network '$network' doesn't exist, will be created"
		fi
	done
}

# ============================================
# Build Images
# ============================================

build_images() {
	log_info "Building images..."

	if [ -f "$SCRIPT_DIR/build-images.sh" ]; then
		bash "$SCRIPT_DIR/build-images.sh"
	else
		log_warning "build-images.sh not found, skipping build"
	fi
}

# ============================================
# Deploy Stack
# ============================================

deploy_stack() {
	log_info "Deploying stack: $STACK_NAME"

	# Deploy main stack
	docker stack deploy -c "$PROJECT_ROOT/docker-stack.yml" "$STACK_NAME"

	# Deploy monitoring stack if exists
	if [ -f "$PROJECT_ROOT/docker-stack.monitoring.yml" ]; then
		log_info "Deploying monitoring stack..."
		docker stack deploy -c "$PROJECT_ROOT/docker-stack.monitoring.yml" "$STACK_NAME"
	fi

	# Deploy logging stack if exists
	if [ -f "$PROJECT_ROOT/docker-stack.logging.yml" ]; then
		log_info "Deploying logging stack..."
		docker stack deploy -c "$PROJECT_ROOT/docker-stack.logging.yml" "$STACK_NAME"
	fi

	log_success "Stack deployed: $STACK_NAME"
}

# ============================================
# Wait for Services
# ============================================

wait_for_services() {
	log_info "Waiting for services to start..."

	local timeout=120
	local elapsed=0
	local interval=5

	while [ $elapsed -lt $timeout ]; do
		# Get service status
		local total
		local running

		total=$(docker service ls -q | wc -l)
		running=$(docker service ls --format '{{.Replicas}}' | grep -c "^[1-9].*/" || true)

		echo -ne "\r  Services: $running/$total ready (${elapsed}s)..."

		if [ "$running" -eq "$total" ] && [ "$total" -gt 0 ]; then
			echo ""
			log_success "All services are running"
			return 0
		fi

		sleep $interval
		((elapsed += interval))
	done

	echo ""
	log_warning "Timeout waiting for services. Some may still be starting."
	return 1
}

# ============================================
# Show Status
# ============================================

show_status() {
	echo ""
	echo "============================================"
	echo "Stack Status: $STACK_NAME"
	echo "============================================"
	echo ""

	docker stack services "$STACK_NAME"

	echo ""
	echo "============================================"
	echo "Access Points"
	echo "============================================"
	echo ""
	echo "  Frontend:    http://localhost"
	echo "  API:         http://localhost/api"
	echo "  Grafana:     http://localhost:3000"
	echo "  Prometheus:  http://localhost:9090"
	echo "  RabbitMQ:    http://localhost:15672"
	echo ""
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Stack Deployment"
	echo "============================================"
	echo ""

	check_swarm
	check_secrets
	check_stack_file
	check_networks

	if [ "$BUILD_FIRST" = true ]; then
		build_images
	fi

	deploy_stack
	wait_for_services
	show_status

	echo ""
	log_success "Deployment complete!"
	echo ""
}

main "$@"
