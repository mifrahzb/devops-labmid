#!/bin/bash

#############################################
# Smoke Test Script for PetClinic Application
# Verifies deployment health and connectivity
#############################################

set -e

# Configuration
APP_URL="${APP_URL:-http://localhost:8080}"
MAX_RETRIES="${MAX_RETRIES:-30}"
RETRY_INTERVAL="${RETRY_INTERVAL:-10}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
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

# Wait for application to be ready
wait_for_app() {
    print_header "WAITING FOR APPLICATION"
    print_info "Target URL: $APP_URL"
    print_info "Max retries: $MAX_RETRIES"
    print_info "Retry interval: ${RETRY_INTERVAL}s"
    echo ""
    
    for i in $(seq 1 $MAX_RETRIES); do
        if curl -sf "$APP_URL/actuator/health" > /dev/null 2>&1; then
            print_success "Application is responding (attempt $i/$MAX_RETRIES)"
            return 0
        fi
        print_info "Waiting for application... (attempt $i/$MAX_RETRIES)"
        sleep $RETRY_INTERVAL
    done
    
    print_error "Application failed to respond after $MAX_RETRIES attempts"
    return 1
}

# Test application health endpoint
test_health_endpoint() {
    print_header "TESTING HEALTH ENDPOINT"
    
    if ! HEALTH_RESPONSE=$(curl -sf "$APP_URL/actuator/health" 2>&1); then
        print_error "Health endpoint not accessible"
        echo "Error: $HEALTH_RESPONSE"
        return 1
    fi
    
    echo "Response: $HEALTH_RESPONSE"
    
    if echo "$HEALTH_RESPONSE" | grep -q '"status":"UP"'; then
        print_success "Health endpoint returned UP status"
    else
        print_error "Health endpoint did not return UP status"
        return 1
    fi
    
    echo ""
}

# Test database connectivity
test_database_connectivity() {
    print_header "TESTING DATABASE CONNECTIVITY"
    
    if ! DB_HEALTH=$(curl -sf "$APP_URL/actuator/health" 2>&1); then
        print_error "Cannot retrieve database health information"
        return 1
    fi
    
    if echo "$DB_HEALTH" | grep -q '"db"'; then
        print_success "Database component found in health response"
        echo "$DB_HEALTH" | grep -A 5 '"db"' || true
    else
        print_info "Database health not separately reported (may be included in overall health)"
    fi
    
    echo ""
}

# Test Redis connectivity
test_redis_connectivity() {
    print_header "TESTING REDIS CONNECTIVITY"
    
    if ! REDIS_HEALTH=$(curl -sf "$APP_URL/actuator/health" 2>&1); then
        print_error "Cannot retrieve Redis health information"
        return 1
    fi
    
    if echo "$REDIS_HEALTH" | grep -q '"redis"'; then
        print_success "Redis component found in health response"
        echo "$REDIS_HEALTH" | grep -A 5 '"redis"' || true
    else
        print_info "Redis health not separately reported (may be included in overall health)"
    fi
    
    echo ""
}

# Test main application endpoint
test_main_endpoint() {
    print_header "TESTING MAIN APPLICATION ENDPOINT"
    
    HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "$APP_URL/" 2>&1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Main endpoint returned HTTP $HTTP_CODE"
    else
        print_error "Main endpoint returned HTTP $HTTP_CODE (expected 200)"
        return 1
    fi
    
    echo ""
}

# Test critical API endpoints
test_critical_endpoints() {
    print_header "TESTING CRITICAL ENDPOINTS"
    
    ENDPOINTS=(
        "/"
        "/actuator/health"
        "/actuator/info"
    )
    
    FAILED=0
    for endpoint in "${ENDPOINTS[@]}"; do
        URL="$APP_URL$endpoint"
        HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "$URL" 2>&1 || echo "000")
        
        if [ "$HTTP_CODE" = "200" ]; then
            print_success "$endpoint - HTTP $HTTP_CODE"
        else
            print_error "$endpoint - HTTP $HTTP_CODE"
            FAILED=1
        fi
    done
    
    echo ""
    
    if [ $FAILED -eq 1 ]; then
        return 1
    fi
}

# Test application metrics (if available)
test_metrics() {
    print_header "TESTING METRICS ENDPOINT"
    
    HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "$APP_URL/actuator/metrics" 2>&1 || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Metrics endpoint is accessible"
    else
        print_info "Metrics endpoint not accessible (may not be enabled)"
    fi
    
    echo ""
}

# Main execution
main() {
    print_header "PETCLINIC SMOKE TEST"
    echo "Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    
    FAILED=0
    
    # Run all tests
    wait_for_app || FAILED=1
    test_health_endpoint || FAILED=1
    test_database_connectivity || FAILED=1
    test_redis_connectivity || FAILED=1
    test_main_endpoint || FAILED=1
    test_critical_endpoints || FAILED=1
    test_metrics || true  # Non-critical
    
    # Final summary
    print_header "SMOKE TEST SUMMARY"
    
    if [ $FAILED -eq 0 ]; then
        print_success "All smoke tests passed!"
        echo ""
        echo "Application is healthy and ready for use."
        echo "Access URL: $APP_URL"
        exit 0
    else
        print_error "Some smoke tests failed!"
        echo ""
        echo "Please check the application logs for more details."
        exit 1
    fi
}

# Run main function
main "$@"
