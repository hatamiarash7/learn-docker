#!/bin/bash
# ============================================
# ShopStream - Create Docker Secrets
# ============================================
# Creates all required secrets for the ShopStream stack.
#
# Usage: ./create-secrets.sh [--generate]
#
# Options:
#   --generate    Auto-generate secure random passwords
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

# ============================================
# Configuration
# ============================================

GENERATE_PASSWORDS=false
SECRETS_DIR=".secrets"

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--generate)
		GENERATE_PASSWORDS=true
		shift
		;;
	-h | --help)
		echo "Usage: $0 [--generate]"
		echo ""
		echo "Options:"
		echo "  --generate    Auto-generate secure random passwords"
		exit 0
		;;
	*)
		log_error "Unknown option: $1"
		exit 1
		;;
	esac
done

# ============================================
# Helper Functions
# ============================================

generate_password() {
	local length=${1:-32}
	openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c "$length"
}

generate_jwt_secret() {
	openssl rand -base64 64 | tr -dc 'a-zA-Z0-9' | head -c 64
}

create_secret() {
	local name=$1
	local value=$2

	# Check if secret already exists
	if docker secret ls --format '{{.Name}}' | grep -q "^${name}$"; then
		log_warning "Secret '$name' already exists, skipping"
		return 0
	fi

	# Create secret
	echo -n "$value" | docker secret create "$name" -
	log_success "Created secret: $name"
}

prompt_password() {
	local name=$1
	local default=$2

	if [ "$GENERATE_PASSWORDS" = true ]; then
		echo "$default"
	else
		read -sp "Enter value for $name (or press Enter for generated): " value
		echo ""
		if [ -z "$value" ]; then
			echo "$default"
		else
			echo "$value"
		fi
	fi
}

# ============================================
# Pre-flight checks
# ============================================

check_swarm() {
	if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
		log_error "This node is not part of a swarm or is not a manager"
		log_error "Run 'docker swarm init' first or run this on a manager node"
		exit 1
	fi
	log_success "Swarm is active"
}

# ============================================
# Create Secrets
# ============================================

create_all_secrets() {
	log "Creating secrets..."

	# Generate or prompt for passwords
	local db_root_pass
	local db_app_pass
	local redis_pass
	local jwt_secret
	local rabbitmq_pass
	local minio_secret
	local grafana_pass
	local es_pass

	if [ "$GENERATE_PASSWORDS" = true ]; then
		log "Auto-generating secure passwords..."
		db_root_pass=$(generate_password 24)
		db_app_pass=$(generate_password 24)
		redis_pass=$(generate_password 24)
		jwt_secret=$(generate_jwt_secret)
		rabbitmq_pass=$(generate_password 24)
		minio_secret=$(generate_password 32)
		grafana_pass=$(generate_password 16)
		es_pass=$(generate_password 24)
	else
		echo ""
		echo "Enter passwords for each secret (or press Enter to auto-generate):"
		echo ""
		db_root_pass=$(prompt_password "db_root_password" "$(generate_password 24)")
		db_app_pass=$(prompt_password "db_password" "$(generate_password 24)")
		redis_pass=$(prompt_password "redis_password" "$(generate_password 24)")
		jwt_secret=$(prompt_password "jwt_secret" "$(generate_jwt_secret)")
		rabbitmq_pass=$(prompt_password "rabbitmq_password" "$(generate_password 24)")
		minio_secret=$(prompt_password "minio_secret_key" "$(generate_password 32)")
		grafana_pass=$(prompt_password "grafana_admin_password" "$(generate_password 16)")
		es_pass=$(prompt_password "elasticsearch_password" "$(generate_password 24)")
	fi

	# Create secrets
	create_secret "db_root_password" "$db_root_pass"
	create_secret "db_password" "$db_app_pass"
	create_secret "redis_password" "$redis_pass"
	create_secret "jwt_secret" "$jwt_secret"
	create_secret "rabbitmq_password" "$rabbitmq_pass"
	create_secret "minio_secret_key" "$minio_secret"
	create_secret "grafana_admin_password" "$grafana_pass"
	create_secret "elasticsearch_password" "$es_pass"

	# Save passwords locally for reference (encrypted or secured)
	mkdir -p "$SECRETS_DIR"
	chmod 700 "$SECRETS_DIR"

	cat >"$SECRETS_DIR/passwords.txt" <<EOF
# ShopStream Secrets - KEEP SECURE!
# Generated: $(date)
# ============================================
# DO NOT COMMIT THIS FILE TO VERSION CONTROL!
# ============================================

db_root_password=$db_root_pass
db_password=$db_app_pass
redis_password=$redis_pass
jwt_secret=$jwt_secret
rabbitmq_password=$rabbitmq_pass
minio_secret_key=$minio_secret
grafana_admin_password=$grafana_pass
elasticsearch_password=$es_pass
EOF

	chmod 600 "$SECRETS_DIR/passwords.txt"

	log_success "Passwords saved to $SECRETS_DIR/passwords.txt"
	log_warning "Keep this file secure and do not commit to version control!"
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Secrets Creation"
	echo "============================================"
	echo ""

	check_swarm
	create_all_secrets

	echo ""
	echo "============================================"
	echo "Secrets created:"
	docker secret ls
	echo "============================================"
	echo ""
	log_success "All secrets created successfully!"
	echo ""
}

main "$@"
