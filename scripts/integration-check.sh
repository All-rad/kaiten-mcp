#!/usr/bin/env bash
#
# scripts/integration-check.sh - Validate packaged archive structure and contents
#
# Verifies that the kaiten-mcp.zip archive contains all required files for
# successful distribution and execution.
#
# Usage:
#   ./scripts/integration-check.sh [archive_path]
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
TEMP_EXTRACT_DIR="/tmp/kaiten-mcp-check-$$"

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

# Function to cleanup temp directory
cleanup() {
  if [ -d "$TEMP_EXTRACT_DIR" ]; then
    rm -rf "$TEMP_EXTRACT_DIR"
  fi
}

trap cleanup EXIT

# Function to check file exists
check_file() {
  local file="$1"
  local description="$2"
  
  if [ -f "$file" ]; then
    local size
    size=$(du -h "$file" | cut -f1)
    log_success "✓ Found $description: $(basename "$file") ($size)"
    return 0
  else
    log_error "✗ Missing $description: $file"
    return 1
  fi
}

# Function to check directory exists
check_dir() {
  local dir="$1"
  local description="$2"
  
  if [ -d "$dir" ]; then
    local count
    count=$(find "$dir" -type f | wc -l)
    log_success "✓ Found $description: $dir ($count files)"
    return 0
  else
    log_error "✗ Missing $description directory: $dir"
    return 1
  fi
}

# Main validation
main() {
  log_info "========================================="
  log_info "Kaiten MCP Integration Check"
  log_info "========================================="
  
  # Check if archive exists
  if [ ! -f "$ARCHIVE" ]; then
    log_error "Archive not found: $ARCHIVE"
    exit 1
  fi
  
  log_info "Archive: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"
  
  # Extract archive to temp location
  log_info "Extracting archive to $TEMP_EXTRACT_DIR..."
  mkdir -p "$TEMP_EXTRACT_DIR"
  
  if command -v unzip &> /dev/null; then
    unzip -q "$ARCHIVE" -d "$TEMP_EXTRACT_DIR"
  else
    log_error "unzip not found in PATH"
    exit 1
  fi
  
  APP_DIR="$TEMP_EXTRACT_DIR/kaiten-mcp"
  
  if [ ! -d "$APP_DIR" ]; then
    log_error "Archive structure invalid: kaiten-mcp/ directory not found"
    exit 1
  fi
  
  log_success "Archive extracted"
  log_info ""
  log_info "Validating package structure..."
  
  # Initialize error counter
  local errors=0
  
  # Check required files
  log_info ""
  log_info "Required files:"
  check_file "$APP_DIR/lib/kaiten-mcp.jar" "Backend JAR" || errors=$((errors + 1))
  check_file "$APP_DIR/static/index.html" "UI Entry Point" || errors=$((errors + 1))
  check_file "$APP_DIR/bin/start.sh" "Linux Start Script" || errors=$((errors + 1))
  check_file "$APP_DIR/bin/stop.sh" "Linux Stop Script" || errors=$((errors + 1))
  check_file "$APP_DIR/bin/start.bat" "Windows Start Script" || errors=$((errors + 1))
  check_file "$APP_DIR/bin/stop.bat" "Windows Stop Script" || errors=$((errors + 1))
  check_file "$APP_DIR/VERSION" "Version File" || errors=$((errors + 1))
  
  # Check directories
  log_info ""
  log_info "Required directories:"
  check_dir "$APP_DIR/lib" "Backend Lib Directory" || errors=$((errors + 1))
  check_dir "$APP_DIR/static" "UI Static Files" || errors=$((errors + 1))
  check_dir "$APP_DIR/bin" "Scripts Directory" || errors=$((errors + 1))
  
  # Optional directories
  log_info ""
  log_info "Optional directories:"
  if [ -d "$APP_DIR/jre" ]; then
    if [ -f "$APP_DIR/jre/bin/java" ] || [ -f "$APP_DIR/jre/bin/java.exe" ]; then
      log_success "✓ JRE found and configured"
    else
      log_warn "JRE directory exists but no Java binary found (expected for CI builds)"
    fi
  else
    log_warn "JRE directory not present (will require system Java)"
  fi
  
  if [ -d "$APP_DIR/config" ]; then
    check_dir "$APP_DIR/config" "Config Directory"
  else
    log_info "Config directory not present (optional)"
  fi
  
  # Check script permissions
  log_info ""
  log_info "Script permissions:"
  if [ -x "$APP_DIR/bin/start.sh" ]; then
    log_success "✓ start.sh is executable"
  else
    log_warn "start.sh is not executable (may need: chmod +x)"
  fi
  
  if [ -x "$APP_DIR/bin/stop.sh" ]; then
    log_success "✓ stop.sh is executable"
  else
    log_warn "stop.sh is not executable (may need: chmod +x)"
  fi
  
  # Summary
  log_info ""
  log_info "========================================="
  
  if [ $errors -eq 0 ]; then
    log_success "Package validation PASSED"
    log_info "========================================="
    log_info "Package is ready for distribution!"
    log_info "To run: unzip $ARCHIVE && cd kaiten-mcp && ./bin/start.sh"
    exit 0
  else
    log_error "Package validation FAILED ($errors errors)"
    log_info "========================================="
    exit 1
  fi
}

main "$@"
