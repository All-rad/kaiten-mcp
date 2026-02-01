#!/bin/bash
#
# backend/bin/stop.sh - Stop the Kaiten MCP backend server
#
# Usage:
#   ./backend/bin/stop.sh    # Stop the running server
#

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$BACKEND_DIR/.server.pid"

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

# Main logic
log_info "Kaiten MCP Backend Stop Script"

if [ ! -f "$PID_FILE" ]; then
  log_error "Server PID file not found: $PID_FILE"
  log_info "The server might not be running"
  exit 1
fi

pid=$(cat "$PID_FILE")

if ! ps -p "$pid" > /dev/null 2>&1; then
  log_error "No process found with PID $pid"
  rm -f "$PID_FILE"
  exit 1
fi

log_info "Stopping server (PID: $pid)..."

# Try graceful shutdown first with SIGTERM
if kill -0 "$pid" 2>/dev/null; then
  kill -TERM "$pid"
  
  # Wait up to 10 seconds for graceful shutdown
  wait_count=0
  while [ $wait_count -lt 20 ] && ps -p "$pid" > /dev/null 2>&1; do
    sleep 0.5
    wait_count=$((wait_count + 1))
  done
  
  # If still running, force kill
  if ps -p "$pid" > /dev/null 2>&1; then
    log_info "Server did not stop gracefully, force killing..."
    kill -9 "$pid" 2>/dev/null || true
  fi
fi

# Clean up PID file
rm -f "$PID_FILE"

log_success "Backend server stopped"

# Clean up log file (optional)
if [ -f "$BACKEND_DIR/server.log" ]; then
  log_info "Server log: $BACKEND_DIR/server.log (you can safely delete it)"
fi
