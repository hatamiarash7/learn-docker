#!/bin/bash
# ============================================
# ShopStream - Health Check
# ============================================
# Checks health of all services in the stack.
#
# Usage: ./health-check.sh [--verbose]
# ============================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ $1${NC}"; }

# ============================================
# Configuration
# ============================================

STACK_NAME="shopstream"
VERBOSE=false
BASE_URL="http://localhost"

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--verbose | -v)
		VERBOSE=true
		shift
		;;
	-h | --help)
		echo "Usage: $0 [--verbose]"
		exit 0
		;;
	*)
		log_error "Unknown option: $1"
		exit 1
		;;
	esac
done

# ============================================
# Check Functions
# ============================================

check_swarm() {
	echo ""
	echo "Swarm Status"
	echo "--------------------------------------------"

	if docker info 2>/dev/null | grep -q "Swarm: active"; then
		log_success "Swarm is active"

		local nodes
		local managers
		local workers

		nodes=$(docker node ls -q | wc -l)
		managers=$(docker node ls -q --filter "role=manager" | wc -l)
		workers=$(docker node ls -q --filter "role=worker" | wc -l)

		echo "  Nodes: $nodes (Managers: $managers, Workers: $workers)"

		if [ "$VERBOSE" = true ]; then
			echo ""
			docker node ls
		fi
	else
		log_error "Swarm is not active"
		return 1
	fi
}

check_services() {
	echo ""
	echo "Service Status"
	echo "--------------------------------------------"

	local services
	services=$(docker stack services "$STACK_NAME" --format '{{.Name}}:{{.Replicas}}' 2>/dev/null || echo "")

	if [ -z "$services" ]; then
		log_warning "No services found for stack: $STACK_NAME"
		return 1
	fi

	local healthy=0
	local unhealthy=0

	while IFS=: read -r name replicas; do
		local current
		local desired

		current=$(echo "$replicas" | cut -d/ -f1)
		desired=$(echo "$replicas" | cut -d/ -f2)

		if [ "$current" -eq "$desired" ] && [ "$desired" -gt 0 ]; then
			log_success "$name ($replicas)"
			((healthy++))
		elif [ "$current" -eq 0 ]; then
			log_error "$name ($replicas)"
			((unhealthy++))
		else
			log_warning "$name ($replicas)"
			((unhealthy++))
		fi
	done <<<"$services"

	echo ""
	echo "  Healthy: $healthy, Unhealthy: $unhealthy"

	return $([ $unhealthy -eq 0 ])
}

check_http_endpoint() {
	local name=$1
	local url=$2
	local expected_code=${3:-200}

	local response
	local http_code

	response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")

	if [ "$response" = "$expected_code" ]; then
		log_success "$name ($url)"
		return 0
	else
		log_error "$name ($url) - HTTP $response"
		return 1
	fi
}

check_endpoints() {
	echo ""
	echo "HTTP Endpoints"
	echo "--------------------------------------------"

	local healthy=0
	local unhealthy=0

	# Check each endpoint
	check_http_endpoint "Frontend" "$BASE_URL/" && ((healthy++)) || ((unhealthy++))
	check_http_endpoint "API Health" "$BASE_URL/api/health" && ((healthy++)) || ((unhealthy++))
	check_http_endpoint "Products API" "$BASE_URL/api/products" && ((healthy++)) || ((unhealthy++))

	# Check monitoring endpoints (different ports)
	check_http_endpoint "Grafana" "http://localhost:3000/api/health" && ((healthy++)) || ((unhealthy++))
	check_http_endpoint "Prometheus" "http://localhost:9090/-/healthy" && ((healthy++)) || ((unhealthy++))

	echo ""
	echo "  Healthy: $healthy, Unhealthy: $unhealthy"

	return $([ $unhealthy -eq 0 ])
}

check_volumes() {
	echo ""
	echo "Volume Status"
	echo "--------------------------------------------"

	local volumes
	volumes=$(docker volume ls --filter "name=${STACK_NAME}_" -q 2>/dev/null || echo "")

	if [ -z "$volumes" ]; then
		log_warning "No volumes found for stack: $STACK_NAME"
		return 0
	fi

	while read -r volume; do
		local size
		size=$(docker system df -v 2>/dev/null | grep "$volume" | awk '{print $4}' || echo "unknown")
		log_success "$volume ($size)"
	done <<<"$volumes"
}

check_networks() {
	echo ""
	echo "Network Status"
	echo "--------------------------------------------"

	local networks=("traefik-public" "frontend" "backend" "data" "monitoring")

	for network in "${networks[@]}"; do
		if docker network ls --format '{{.Name}}' | grep -q "^${network}$"; then
			local driver
			driver=$(docker network inspect "$network" --format '{{.Driver}}' 2>/dev/null || echo "unknown")
			log_success "$network (driver: $driver)"
		else
			log_error "$network (not found)"
		fi
	done
}

check_secrets() {
	echo ""
	echo "Secrets Status"
	echo "--------------------------------------------"

	local secrets
	secrets=$(docker secret ls -q 2>/dev/null | wc -l)

	log_info "$secrets secrets configured"

	if [ "$VERBOSE" = true ]; then
		docker secret ls
	fi
}

# ============================================
# Generate Report
# ============================================

generate_report() {
	echo ""
	echo "============================================"
	echo "Health Check Report"
	echo "============================================"
	echo ""
	echo "Timestamp: $(date)"
	echo "Stack: $STACK_NAME"
	echo ""
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Health Check"
	echo "============================================"

	local exit_code=0

	check_swarm || exit_code=1
	check_services || exit_code=1
	check_endpoints || exit_code=1
	check_volumes
	check_networks
	check_secrets

	generate_report

	if [ $exit_code -eq 0 ]; then
		log_success "All health checks passed!"
	else
		log_error "Some health checks failed!"
	fi

	echo ""

	exit $exit_code
}

main "$@"
