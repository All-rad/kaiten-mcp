#!/bin/bash
#
# backend/bin/start.sh - Start the Kaiten MCP backend server
#
# Usage:
#   ./backend/bin/start.sh      # Build and start the server
#   ./backend/bin/start.sh -s   # Start only (skip build)
#
# TODO: Add support for custom JVM arguments (memory, GC tuning)
# TODO: Implement health check endpoint polling for readiness
# TODO: Add systemd service integration for production deployments
# TODO: Consider adding hot-reload capability for development
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$BACKEND_DIR/.." && pwd)"
JAR_FILE="$BACKEND_DIR/target/kaiten-mcp*.jar"
PID_FILE="$BACKEND_DIR/.server.pid"
SERVER_PORT="${SERVER_PORT:-8080}"
SKIP_BUILD="${1:-}"

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

# Function to check if server is already running
check_running() {
  if [ -f "$PID_FILE" ]; then
    local pid=$(cat "$PID_FILE")
    if ps -p "$pid" > /dev/null 2>&1; then
      log_error "Server is already running (PID: $pid)"
      log_info "To stop the server, run: ./backend/bin/stop.sh"
      exit 1
    else
      # PID file exists but process is not running
      rm -f "$PID_FILE"
    fi
  fi
}

# Function to build the backend
build_backend() {
  log_info "Building backend..."
  cd "$BACKEND_DIR"
  
  if ! command -v mvn &> /dev/null; then
    log_error "Maven is not installed or not in PATH"
    exit 1
  fi
  
  if mvn clean package -q -DskipTests; then
    log_success "Backend build completed"
  else
    log_error "Backend build failed"
    exit 1
  fi
}

# Function to start the server
start_server() {
  log_info "Starting backend server on port $SERVER_PORT..."
  
  # Find the JAR file (may have version suffix)
  local jar_path
  jar_path=$(ls "$BACKEND_DIR"/target/kaiten-mcp*.jar 2>/dev/null | grep -v '.original' | head -1)
  
  if [ -z "$jar_path" ] || [ ! -f "$jar_path" ]; then
    log_error "JAR file not found in: $BACKEND_DIR/target/"
    log_info "Run 'mvn package' to build the backend"
    exit 1
  fi
  
  cd "$BACKEND_DIR"
  
  # Start server in background
  if java -jar "$jar_path" > "$BACKEND_DIR/server.log" 2>&1 &
  then
    local pid=$!
    echo "$pid" > "$PID_FILE"
    log_success "Backend server started (PID: $pid)"
    log_info "Server logs: tail -f $BACKEND_DIR/server.log"
    log_info "Server is running on http://localhost:$SERVER_PORT"
  else
    log_error "Failed to start backend server"
    exit 1
  fi
}

# Main logic
log_info "Kaiten MCP Backend Start Script"

check_running

if [ "$SKIP_BUILD" != "-s" ]; then
  build_backend
else
  log_info "Skipping build (-s flag)"
fi

start_server

# Wait a moment for the server to fully initialize
sleep 2

# Check if server is actually running
if ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
  log_success "Backend server is running and healthy"
  log_info "Test the endpoint: curl -s http://localhost:$SERVER_PORT/hello/World | jq"
else
  log_error "Server failed to start"
  rm -f "$PID_FILE"
  log_error "Check logs: tail -20 $BACKEND_DIR/server.log"
  exit 1
fi
