#!/bin/bash
# ============================================
# ShopStream - Smoke Test
# ============================================
# Runs basic functionality tests to verify
# the platform is working correctly.
#
# Usage: ./smoke-test.sh [--base-url URL]
# ============================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# Configuration
# ============================================

BASE_URL="${BASE_URL:-http://localhost}"
API_URL="$BASE_URL/api"
PASSED=0
FAILED=0

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--base-url)
		BASE_URL="$2"
		API_URL="$BASE_URL/api"
		shift 2
		;;
	-h | --help)
		echo "Usage: $0 [--base-url URL]"
		exit 0
		;;
	*)
		shift
		;;
	esac
done

# ============================================
# Test Functions
# ============================================

test_pass() {
	echo -e "  ${GREEN}✓ PASS${NC}: $1"
	((PASSED++))
}

test_fail() {
	echo -e "  ${RED}✗ FAIL${NC}: $1"
	echo -e "    ${YELLOW}→ $2${NC}"
	((FAILED++))
}

test_skip() {
	echo -e "  ${YELLOW}○ SKIP${NC}: $1"
}

http_test() {
	local name=$1
	local method=$2
	local url=$3
	local expected_code=${4:-200}
	local data=${5:-}

	local response
	local http_code
	local body

	if [ -n "$data" ]; then
		response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null || echo -e "\n000")
	else
		response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" 2>/dev/null || echo -e "\n000")
	fi

	http_code=$(echo "$response" | tail -n1)
	body=$(echo "$response" | sed '$d')

	if [ "$http_code" = "$expected_code" ]; then
		test_pass "$name"
		return 0
	else
		test_fail "$name" "Expected HTTP $expected_code, got $http_code"
		return 1
	fi
}

# ============================================
# Test Suites
# ============================================

test_frontend() {
	echo ""
	echo "Testing Frontend..."
	echo "--------------------------------------------"

	http_test "Frontend loads" GET "$BASE_URL/"
	http_test "Frontend health" GET "$BASE_URL/health"
}

test_api_gateway() {
	echo ""
	echo "Testing API Gateway..."
	echo "--------------------------------------------"

	http_test "API health check" GET "$API_URL/health"
}

test_products() {
	echo ""
	echo "Testing Product Service..."
	echo "--------------------------------------------"

	http_test "List products" GET "$API_URL/products"
	http_test "Search products" GET "$API_URL/products/search?q=laptop"
}

test_auth() {
	echo ""
	echo "Testing Auth Service..."
	echo "--------------------------------------------"

	# Generate random email for test
	local test_email="test_$(date +%s)@example.com"
	local test_password="testpass123"

	# Register
	local register_response
	register_response=$(curl -s -X POST "$API_URL/auth/register" \
		-H "Content-Type: application/json" \
		-d "{\"name\":\"Test User\",\"email\":\"$test_email\",\"password\":\"$test_password\"}" 2>/dev/null)

	if echo "$register_response" | grep -q "userId\|success"; then
		test_pass "User registration"
	else
		test_fail "User registration" "Failed to register user"
	fi

	# Login
	local login_response
	login_response=$(curl -s -X POST "$API_URL/auth/login" \
		-H "Content-Type: application/json" \
		-d "{\"email\":\"$test_email\",\"password\":\"$test_password\"}" 2>/dev/null)

	if echo "$login_response" | grep -q "token"; then
		test_pass "User login"

		# Extract token for further tests
		TOKEN=$(echo "$login_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

		# Test authenticated endpoint
		local me_response
		me_response=$(curl -s -X GET "$API_URL/auth/me" \
			-H "Authorization: Bearer $TOKEN" 2>/dev/null)

		if echo "$me_response" | grep -q "email"; then
			test_pass "Get current user"
		else
			test_fail "Get current user" "Failed to get user info"
		fi
	else
		test_fail "User login" "Failed to login"
		test_skip "Get current user (requires login)"
	fi
}

test_orders() {
	echo ""
	echo "Testing Order Service..."
	echo "--------------------------------------------"

	if [ -n "${TOKEN:-}" ]; then
		# Test getting orders (should be empty for new user)
		local orders_response
		orders_response=$(curl -s -X GET "$API_URL/orders" \
			-H "Authorization: Bearer $TOKEN" 2>/dev/null)

		if echo "$orders_response" | grep -qE '^\['; then
			test_pass "Get orders"
		else
			test_fail "Get orders" "Failed to get orders"
		fi
	else
		test_skip "Get orders (requires login)"
	fi
}

test_monitoring() {
	echo ""
	echo "Testing Monitoring..."
	echo "--------------------------------------------"

	http_test "Prometheus" GET "http://localhost:9090/-/healthy"
	http_test "Grafana" GET "http://localhost:3000/api/health"
}

# ============================================
# Main
# ============================================

main() {
	echo ""
	echo "============================================"
	echo "   ShopStream Smoke Tests"
	echo "============================================"
	echo ""
	echo "Base URL: $BASE_URL"
	echo "API URL:  $API_URL"

	# Run tests
	test_frontend
	test_api_gateway
	test_products
	test_auth
	test_orders
	test_monitoring

	# Summary
	echo ""
	echo "============================================"
	echo "Test Summary"
	echo "============================================"
	echo ""
	echo -e "  ${GREEN}Passed${NC}: $PASSED"
	echo -e "  ${RED}Failed${NC}: $FAILED"
	echo ""

	local total=$((PASSED + FAILED))
	local percentage=$((PASSED * 100 / total))

	echo "  Success Rate: $percentage%"
	echo ""

	if [ $FAILED -gt 0 ]; then
		echo -e "${RED}Some tests failed!${NC}"
		exit 1
	else
		echo -e "${GREEN}All tests passed!${NC}"
		exit 0
	fi
}

main "$@"
