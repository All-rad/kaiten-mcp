#!/bin/bash
#
# tests/smoke/smoke-ui-build.sh - Validate UI build artifacts
#
# This script verifies that the UI build produces the expected artifacts:
# - dist/ directory exists
# - dist/index.html exists
# - dist/assets/ directory with compiled JavaScript
#
# Usage:
#   ./tests/smoke/smoke-ui-build.sh     # Check existing dist/
#   ./tests/smoke/smoke-ui-build.sh -b  # Build and then check
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
UI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/ui"
DIST_DIR="$UI_DIR/dist"
BUILD_FLAG="${1:-}"

# Helper functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Function to build the UI
build_ui() {
  log_info "Building UI..."
  cd "$UI_DIR"
  
  if [ ! -f "package.json" ]; then
    log_error "package.json not found in: $UI_DIR"
    exit 1
  fi
  
  if ! npm run build; then
    log_error "UI build failed"
    exit 1
  fi
  
  log_success "UI build completed"
}

# Function to validate build artifacts
validate_artifacts() {
  log_info "Validating UI build artifacts..."
  
  # Check if dist directory exists
  if [ ! -d "$DIST_DIR" ]; then
    log_error "dist/ directory not found: $DIST_DIR"
    exit 1
  fi
  log_success "dist/ directory found"
  
  # Check if index.html exists
  if [ ! -f "$DIST_DIR/index.html" ]; then
    log_error "dist/index.html not found"
    exit 1
  fi
  log_success "dist/index.html found ($(wc -c < "$DIST_DIR/index.html") bytes)"
  
  # Check if assets directory exists
  if [ ! -d "$DIST_DIR/assets" ]; then
    log_error "dist/assets/ directory not found"
    exit 1
  fi
  log_success "dist/assets/ directory found"
  
  # Check if JavaScript assets exist
  local js_files
  js_files=$(find "$DIST_DIR/assets" -name "*.js" 2>/dev/null | wc -l)
  if [ "$js_files" -eq 0 ]; then
    log_error "No JavaScript files found in dist/assets/"
    exit 1
  fi
  log_success "Found $js_files JavaScript file(s) in dist/assets/"
  
  # Check if CSS assets exist (or are bundled in JS)
  local css_files
  css_files=$(find "$DIST_DIR/assets" -name "*.css" 2>/dev/null | wc -l)
  if [ "$css_files" -gt 0 ]; then
    log_success "Found $css_files CSS file(s) in dist/assets/"
  else
    log_info "No separate CSS files (CSS likely bundled in JavaScript)"
  fi
  
  # List all artifacts
  log_info "Build artifacts:"
  du -sh "$DIST_DIR"
  find "$DIST_DIR" -type f -printf "  %p (%s bytes)\n" | head -20
}

# Main logic
log_info "Kaiten MCP UI Build Smoke Test"

if [ "$BUILD_FLAG" = "-b" ] || [ "$BUILD_FLAG" = "--build" ]; then
  build_ui
fi

validate_artifacts

log_success "UI build validation passed!"
