#!/bin/bash
# ============================================
# ShopStream - Initialize Swarm Cluster
# ============================================
# This script initializes the Docker Swarm cluster
# with 1 manager and 2 worker nodes.
#
# Usage: ./init-swarm.sh
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
# Pre-flight checks
# ============================================

check_docker() {
	if ! command -v docker &>/dev/null; then
		log_error "Docker is not installed"
		exit 1
	fi

	if ! docker info &>/dev/null; then
		log_error "Docker daemon is not running"
		exit 1
	fi

	log_success "Docker is running"
}

check_existing_swarm() {
	if docker info 2>/dev/null | grep -q "Swarm: active"; then
		log_warning "This node is already part of a swarm"
		read -p "Do you want to leave the current swarm? (y/N): " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			docker swarm leave --force 2>/dev/null || true
			log_success "Left existing swarm"
		else
			log_error "Cannot initialize swarm while already in a swarm"
			exit 1
		fi
	fi
}

# ============================================
# Get network interface
# ============================================

get_advertise_addr() {
	# Try to get the default interface IP
	local ip=""

	# Method 1: Use ip route
	if command -v ip &>/dev/null; then
		ip=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
	fi

	# Method 2: Use hostname
	if [ -z "$ip" ]; then
		ip=$(hostname -I 2>/dev/null | awk '{print $1}')
	fi

	# Method 3: Use ifconfig
	if [ -z "$ip" ]; then
		ip=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
	fi

	if [ -z "$ip" ]; then
		log_error "Could not determine IP address"
		exit 1
	fi

	echo "$ip"
}

# ============================================
# Initialize Swarm
# ============================================

init_swarm() {
	local advertise_addr
	advertise_addr=$(get_advertise_addr)

	log_info "Initializing swarm with advertise address: $advertise_addr"

	docker swarm init --advertise-addr "$advertise_addr"

	log_success "Swarm initialized"
}

# ============================================
# Get join tokens
# ============================================

get_tokens() {
	log_info "Retrieving join tokens..."

	local manager_token
	local worker_token

	manager_token=$(docker swarm join-token manager -q)
	worker_token=$(docker swarm join-token worker -q)

	# Save tokens to file (for automation)
	mkdir -p .swarm
	echo "$manager_token" >.swarm/manager-token
	echo "$worker_token" >.swarm/worker-token
	chmod 600 .swarm/*-token

	log_success "Tokens saved to .swarm/ directory"

	# Display join commands
	local manager_ip
	manager_ip=$(get_advertise_addr)

	echo ""
	echo "============================================"
	echo "SWARM JOIN COMMANDS"
	echo "============================================"
	echo ""
	echo -e "${YELLOW}To add a WORKER node, run:${NC}"
	echo ""
	echo "docker swarm join --token $worker_token $manager_ip:2377"
	echo ""
	echo -e "${YELLOW}To add a MANAGER node, run:${NC}"
	echo ""
	echo "docker swarm join --token $manager_token $manager_ip:2377"
	echo ""
	echo "============================================"
}

# ============================================
# Setup node labels
# ============================================

setup_labels() {
	log_info "Setting up node labels..."

	local node_id
	node_id=$(docker node ls -q --filter "role=manager" | head -n1)

	# Add database label to manager (databases should run on manager for simplicity)
	docker node update --label-add db=true "$node_id"
	docker node update --label-add role=primary "$node_id"

	log_success "Node labels configured"
}

# ============================================
# Create networks
# ============================================

create_networks() {
	log_info "Creating overlay networks..."

	# Check if networks exist, create if not
	docker network create --driver overlay --attachable traefik-public 2>/dev/null && log_success "Created: traefik-public" || log_warning "traefik-public already exists"
	docker network create --driver overlay --attachable frontend 2>/dev/null && log_success "Created: frontend" || log_warning "frontend already exists"
	docker network create --driver overlay --attachable --internal backend 2>/dev/null && log_success "Created: backend (internal)" || log_warning "backend already exists"
	docker network create --driver overlay --attachable --internal data 2>/dev/null && log_success "Created: data (internal)" || log_warning "data already exists"
	docker network create --driver overlay --attachable monitoring 2>/dev/null && log_success "Created: monitoring" || log_warning "monitoring already exists"

	log_success "All networks created"
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Swarm Initialization"
	echo "============================================"
	echo ""

	check_docker
	check_existing_swarm
	init_swarm
	get_tokens
	setup_labels
	create_networks

	echo ""
	log_success "Swarm cluster is ready!"
	echo ""
	echo "Next steps:"
	echo "  1. Join worker nodes using the command above"
	echo "  2. Run ./scripts/cluster/setup-labels.sh after workers join"
	echo "  3. Run ./scripts/secrets/create-secrets.sh"
	echo "  4. Run ./scripts/deploy/deploy-stack.sh"
	echo ""
}

main "$@"
