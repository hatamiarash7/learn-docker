#!/bin/bash
# ============================================
# ShopStream - Build All Images
# ============================================
# Builds all custom Docker images for ShopStream.
#
# Usage: ./build-images.sh [--push] [--tag TAG]
#
# Options:
#   --push      Push images to registry after building
#   --tag TAG   Use specific tag (default: latest)
#   --no-cache  Build without cache
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
SERVICES_DIR="$PROJECT_ROOT/services"

REGISTRY="${REGISTRY:-shopstream}"
TAG="latest"
PUSH=false
NO_CACHE=""

# Services to build
SERVICES=(
	"frontend"
	"api-gateway"
	"auth-service"
	"product-service"
	"order-service"
	"notification-service"
)

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--push)
		PUSH=true
		shift
		;;
	--tag)
		TAG="$2"
		shift 2
		;;
	--no-cache)
		NO_CACHE="--no-cache"
		shift
		;;
	-h | --help)
		echo "Usage: $0 [--push] [--tag TAG] [--no-cache]"
		exit 0
		;;
	*)
		log_error "Unknown option: $1"
		exit 1
		;;
	esac
done

# ============================================
# Build Functions
# ============================================

check_dockerfile() {
	local service=$1
	local dockerfile="$SERVICES_DIR/$service/Dockerfile"

	if [ ! -f "$dockerfile" ]; then
		log_error "Dockerfile not found for $service"
		log_info "Expected: $dockerfile"
		log_info "Please create the Dockerfile for this service"
		return 1
	fi

	return 0
}

build_image() {
	local service=$1
	local image_name="$REGISTRY/$service:$TAG"
	local context="$SERVICES_DIR/$service"

	log_info "Building $image_name..."

	if ! check_dockerfile "$service"; then
		return 1
	fi

	# Build the image
	if docker build $NO_CACHE -t "$image_name" "$context"; then
		log_success "Built: $image_name"

		# Also tag as latest if we're using a version tag
		if [ "$TAG" != "latest" ]; then
			docker tag "$image_name" "$REGISTRY/$service:latest"
		fi

		return 0
	else
		log_error "Failed to build: $image_name"
		return 1
	fi
}

push_image() {
	local service=$1
	local image_name="$REGISTRY/$service:$TAG"

	log_info "Pushing $image_name..."

	if docker push "$image_name"; then
		log_success "Pushed: $image_name"
		return 0
	else
		log_error "Failed to push: $image_name"
		return 1
	fi
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Image Builder"
	echo "============================================"
	echo ""
	echo "Registry: $REGISTRY"
	echo "Tag: $TAG"
	echo "Push: $PUSH"
	echo ""

	local built=0
	local failed=0
	local skipped=0

	for service in "${SERVICES[@]}"; do
		echo ""
		echo "--------------------------------------------"
		echo "Building: $service"
		echo "--------------------------------------------"

		if build_image "$service"; then
			((built++))

			if [ "$PUSH" = true ]; then
				push_image "$service" || ((failed++))
			fi
		else
			((failed++))
		fi
	done

	echo ""
	echo "============================================"
	echo "Build Summary"
	echo "============================================"
	echo ""
	echo -e "Built:   ${GREEN}$built${NC}"
	echo -e "Failed:  ${RED}$failed${NC}"
	echo ""

	if [ $failed -gt 0 ]; then
		log_warning "Some builds failed. Check the Dockerfiles and try again."
		exit 1
	fi

	log_success "All images built successfully!"

	echo ""
	echo "Built images:"
	docker images "$REGISTRY/*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
	echo ""
}

main "$@"
