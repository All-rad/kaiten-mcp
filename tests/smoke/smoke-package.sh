#!/bin/bash
#
# tests/smoke/smoke-package.sh - Smoke test for packaged Kaiten MCP application
#
# This script tests the complete packaged application:
# 1. Extracts kaiten-mcp.zip to a temporary location
# 2. Starts the server from the packaged start script
# 3. Verifies API endpoints work correctly
# 4. Tests UI accessibility
# 5. Stops the server cleanly
#
# Usage:
#   ./tests/smoke/smoke-package.sh              # Use default out/kaiten-mcp.zip
#   ./tests/smoke/smoke-package.sh /path/to/archive.zip
#
# TODO: Add stress testing (concurrent requests)
# TODO: Implement memory profiling during smoke test
# TODO: Add performance metrics collection (response time, throughput)
# TODO: Consider adding Docker-based smoke test execution
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
ARCHIVE="${1:-out/kaiten-mcp.zip}"
TEMP_DIR="/tmp/kaiten-mcp-smoke-test-$$"
APP_DIR="$TEMP_DIR/kaiten-mcp"
SERVER_PORT="${SERVER_PORT:-8080}"
MAX_RETRIES=30
RETRY_DELAY=1

# Helper functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Cleanup function
cleanup() {
  log_info "Cleaning up..."
  
  # Try to stop server if running
  if [ -d "$APP_DIR" ] && [ -f "$APP_DIR/.server.pid" ]; then
    pid=$(cat "$APP_DIR/.server.pid" 2>/dev/null || echo "")
    if [ -n "$pid" ] && ps -p "$pid" > /dev/null 2>&1; then
      log_info "Stopping server (PID: $pid)..."
      kill -TERM "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true
      sleep 1
    fi
  fi
  
  # Remove temp directory
  if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
  fi
}

trap cleanup EXIT

# Function to wait for server
wait_for_server() {
  local retry=0
  
  log_info "Waiting for server to start..."
  
  while [ $retry -lt $MAX_RETRIES ]; do
    if curl -s "http://localhost:$SERVER_PORT/hello/Test" > /dev/null 2>&1; then
      log_success "Server is responding on port $SERVER_PORT"
      return 0
    fi
    
    retry=$((retry + 1))
    sleep $RETRY_DELAY
  done
  
  log_error "Server failed to start after ${MAX_RETRIES}s"
  return 1
}

# Function to test API endpoint
test_api_endpoint() {
  local name="$1"
  local expected_response="$2"
  
  log_info "Testing: GET /hello/$name"
  
  local response
  response=$(curl -s "http://localhost:$SERVER_PORT/hello/$name")
  
  if echo "$response" | grep -q "$expected_response"; then
    log_success "✓ Response contains expected text: $expected_response"
    return 0
  else
    log_error "✗ Unexpected response: $response"
    return 1
  fi
}

# Function to test UI accessibility
test_ui_access() {
  log_info "Testing UI accessibility..."
  
  local response
  response=$(curl -s "http://localhost:$SERVER_PORT/")
  
  if echo "$response" | grep -q "index.html\|<html\|<!DOCTYPE" || echo "$response" | grep -q "React"; then
    log_success "✓ UI is accessible"
    return 0
  else
    log_error "✗ UI not accessible or invalid response"
    log_info "Response: $response" | head -5
    return 1
  fi
}

# Main test workflow
main() {
  log_info "========================================="
  log_info "Kaiten MCP Packaged Smoke Test"
  log_info "========================================="
  log_info "Archive: $ARCHIVE"
  log_info "Temp directory: $TEMP_DIR"
  log_info "Server port: $SERVER_PORT"
  log_info "========================================="
  
  # Verify archive exists
  if [ ! -f "$ARCHIVE" ]; then
    log_error "Archive not found: $ARCHIVE"
    exit 1
  fi
  
  log_success "Archive found"
  
  # Extract archive
  log_info "Extracting archive..."
  mkdir -p "$TEMP_DIR"
  
  if ! unzip -q "$ARCHIVE" -d "$TEMP_DIR"; then
    log_error "Failed to extract archive"
    exit 1
  fi
  
  log_success "Archive extracted"
  
  # Verify structure
  if [ ! -d "$APP_DIR" ]; then
    log_error "Application directory not found: $APP_DIR"
    exit 1
  fi
  
  if [ ! -f "$APP_DIR/bin/start.sh" ]; then
    log_error "start.sh not found in package"
    exit 1
  fi
  
  if [ ! -f "$APP_DIR/lib/kaiten-mcp.jar" ]; then
    log_error "kaiten-mcp.jar not found in package"
    exit 1
  fi
  
  log_success "Package structure verified"
  
  # Start server
  log_info "Starting server from package..."
  cd "$APP_DIR"
  
  # Make scripts executable (in case permissions weren't preserved)
  chmod +x "bin/start.sh" "bin/stop.sh" 2>/dev/null || true
  
  if ! bash "bin/start.sh" > /dev/null 2>&1; then
    log_error "Failed to start server"
    cat "$APP_DIR/server.log" 2>/dev/null || true
    exit 1
  fi
  
  log_success "Server started"
  
  # Wait for server to be ready
  if ! wait_for_server; then
    log_error "Server is not responding"
    cat "$APP_DIR/server.log" 2>/dev/null || true
    exit 1
  fi
  
  # Run API tests
  log_info ""
  log_info "Running API tests..."
  local test_errors=0
  
  test_api_endpoint "World" "Hello, World" || test_errors=$((test_errors + 1))
  test_api_endpoint "Иван" "Hello, Иван" || test_errors=$((test_errors + 1))
  
  # Test validation (missing name)
  log_info "Testing validation: GET /hello (missing name)"
  local http_code
  http_code=$(curl -s -w "%{http_code}" -o /dev/null "http://localhost:$SERVER_PORT/hello")
  if [ "$http_code" = "400" ]; then
    log_success "✓ Missing name validation works (HTTP 400)"
  else
    log_warn "Unexpected HTTP code: $http_code (expected 400)"
  fi
  
  # Test validation (too long name)
  log_info "Testing validation: GET /hello/<long-name>"
  local long_name
  long_name=$(python3 -c "print('a' * 300)")
  http_code=$(curl -s -w "%{http_code}" -o /dev/null "http://localhost:$SERVER_PORT/hello/$long_name")
  if [ "$http_code" = "400" ]; then
    log_success "✓ Too-long name validation works (HTTP 400)"
  else
    log_warn "Unexpected HTTP code: $http_code (expected 400)"
  fi
  
  # Test UI
  log_info ""
  log_info "Testing UI..."
  test_ui_access || test_errors=$((test_errors + 1))
  
  # Stop server
  log_info ""
  log_info "Stopping server..."
  if [ -f "bin/stop.sh" ]; then
    bash "bin/stop.sh" > /dev/null 2>&1 || log_warn "stop.sh returned error"
    log_success "Server stopped"
  fi
  
  # Summary
  log_info ""
  log_info "========================================="
  
  if [ $test_errors -eq 0 ]; then
    log_success "All tests PASSED"
    log_info "========================================="
    log_info "Package smoke test completed successfully!"
    exit 0
  else
    log_error "Some tests FAILED ($test_errors errors)"
    log_info "========================================="
    exit 1
  fi
}

main "$@"
