#!/usr/bin/env bash
#
# build.sh - Unified build script for Kaiten MCP
#
# Builds UI and backend, bundles with JRE, and creates distribution package.
#
# Usage:
#   ./build.sh              # Full build with JRE download
#   ./build.sh --no-jre     # Build without JRE (for CI or if JRE already present)
#   ./build.sh --skip-ui    # Skip UI build (backend only)
#
# TODO: Consider adding Docker support to containerize the build process
# TODO: Add multi-architecture JRE support (ARM64, x86_64 detection)
# TODO: Compress JAR and assets to reduce package size (~15% potential savings)
# TODO: Add build caching to speed up incremental builds
# TODO: Consider adding artifact signing for distribution verification
#   ./build.sh --skip-backend  # Skip backend build (UI only)
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UI_DIR="$PROJECT_ROOT/ui"
BACKEND_DIR="$PROJECT_ROOT/backend"
OUT_DIR="$PROJECT_ROOT/out"
APP_DIR="$OUT_DIR/kaiten-mcp"
BUILD_VERSION="${BUILD_VERSION:-0.1.0}"
SKIP_JRE="${SKIP_JRE:-false}"
SKIP_UI="${SKIP_UI:-false}"
SKIP_BACKEND="${SKIP_BACKEND:-false}"

# Parse command line arguments
for arg in "$@"; do
  case "$arg" in
    --no-jre) SKIP_JRE=true ;;
    --skip-ui) SKIP_UI=true ;;
    --skip-backend) SKIP_BACKEND=true ;;
  esac
done

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

# Function to build UI
build_ui() {
  log_info "Building UI..."
  
  if [ ! -d "$UI_DIR" ]; then
    log_error "UI directory not found: $UI_DIR"
    return 1
  fi
  
  cd "$UI_DIR"
  
  if [ ! -f "package.json" ]; then
    log_error "package.json not found in UI directory"
    return 1
  fi
  
  log_info "Installing UI dependencies..."
  npm install --quiet
  
  log_info "Running UI tests..."
  npm test -- --passWithNoTests
  
  log_info "Building UI for production..."
  npm run build
  
  log_success "UI build completed: $UI_DIR/dist/"
}

# Function to build backend
build_backend() {
  log_info "Building backend..."
  
  if [ ! -d "$BACKEND_DIR" ]; then
    log_error "Backend directory not found: $BACKEND_DIR"
    return 1
  fi
  
  cd "$BACKEND_DIR"
  
  if [ ! -f "pom.xml" ]; then
    log_error "pom.xml not found in backend directory"
    return 1
  fi
  
  if ! command -v mvn &> /dev/null; then
    log_error "Maven not found in PATH"
    return 1
  fi
  
  log_info "Building backend JAR..."
  mvn clean package -q -DskipTests
  
  # Find the built JAR
  JAR_FILE=$(find "$BACKEND_DIR/target" -name "kaiten-mcp*.jar" ! -name "*.original" | head -1)
  if [ -z "$JAR_FILE" ]; then
    log_error "Backend JAR not found after build"
    return 1
  fi
  
  log_success "Backend build completed: $JAR_FILE"
}

# Function to download and prepare JRE
prepare_jre() {
  if [ "$SKIP_JRE" = "true" ]; then
    log_warn "JRE download skipped (--no-jre flag)"
    return 0
  fi
  
  log_info "Downloading and preparing JRE..."
  
  # Check if fetch-jre script exists
  if [ -f "$PROJECT_ROOT/scripts/fetch-jre.sh" ]; then
    log_info "Running JRE fetch script..."
    bash "$PROJECT_ROOT/scripts/fetch-jre.sh" "$APP_DIR/jre"
  else
    log_warn "fetch-jre.sh not found, creating jre directory placeholder"
    mkdir -p "$APP_DIR/jre"
  fi
  
  log_success "JRE prepared"
}

# Function to assemble package
assemble_package() {
  log_info "Assembling package structure..."
  
  # Clean and create directories
  if [ -d "$APP_DIR" ]; then
    log_info "Cleaning existing package directory..."
    rm -rf "$APP_DIR"
  fi
  
  mkdir -p "$APP_DIR"/{lib,static,bin,config,jre}
  
  # Copy backend JAR
  JAR_FILE=$(find "$BACKEND_DIR/target" -name "kaiten-mcp*.jar" ! -name "*.original" | head -1)
  if [ -z "$JAR_FILE" ]; then
    log_error "Backend JAR not found"
    return 1
  fi
  cp "$JAR_FILE" "$APP_DIR/lib/kaiten-mcp.jar"
  log_success "Copied JAR: lib/kaiten-mcp.jar"
  
  # Copy UI static files
  if [ -d "$UI_DIR/dist" ]; then
    cp -r "$UI_DIR/dist"/* "$APP_DIR/static/" 2>/dev/null || true
    log_success "Copied UI artifacts: static/"
  fi
  
  # Generate start scripts
  generate_start_script_sh "$APP_DIR/bin/start.sh"
  generate_stop_script_sh "$APP_DIR/bin/stop.sh"
  generate_start_script_bat "$APP_DIR/bin/start.bat"
  generate_stop_script_bat "$APP_DIR/bin/stop.bat"
  
  # Make shell scripts executable
  chmod +x "$APP_DIR/bin/start.sh" "$APP_DIR/bin/stop.sh"
  
  # Create version file
  echo "$BUILD_VERSION" > "$APP_DIR/VERSION"
  
  log_success "Package assembled at: $APP_DIR"
}

# Function to generate start.sh script
generate_start_script_sh() {
  local script_path="$1"
  cat > "$script_path" << 'SCRIPT_EOF'
#!/bin/bash
# start.sh - Start Kaiten MCP server

set -e

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JAR_FILE="$APP_DIR/lib/kaiten-mcp.jar"
PID_FILE="$APP_DIR/.server.pid"
SERVER_PORT="${SERVER_PORT:-8080}"
UI_PORT="${UI_PORT:-3000}"

if [ ! -f "$JAR_FILE" ]; then
  echo "[ERROR] JAR file not found: $JAR_FILE" >&2
  exit 1
fi

echo "[INFO] Starting Kaiten MCP server on port $SERVER_PORT..."

# Determine which JRE to use
if [ -d "$APP_DIR/jre" ]; then
  JAVA="$APP_DIR/jre/bin/java"
  if [ ! -f "$JAVA" ]; then
    echo "[WARN] Bundled JRE not found, using system java"
    JAVA="java"
  fi
else
  JAVA="java"
fi

# Start server
$JAVA -jar "$JAR_FILE" > "$APP_DIR/server.log" 2>&1 &
pid=$!
echo "$pid" > "$PID_FILE"

echo "[SUCCESS] Server started (PID: $pid)"
sleep 2

# Try to open browser
if command -v xdg-open &> /dev/null; then
  xdg-open "http://localhost:$SERVER_PORT" 2>/dev/null || true
elif command -v open &> /dev/null; then
  open "http://localhost:$SERVER_PORT" 2>/dev/null || true
fi

echo "[INFO] UI available at http://localhost:$SERVER_PORT"
echo "[INFO] Server logs: tail -f $APP_DIR/server.log"
SCRIPT_EOF
}

# Function to generate stop.sh script
generate_stop_script_sh() {
  local script_path="$1"
  cat > "$script_path" << 'SCRIPT_EOF'
#!/bin/bash
# stop.sh - Stop Kaiten MCP server

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$APP_DIR/.server.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "[ERROR] PID file not found" >&2
  exit 1
fi

pid=$(cat "$PID_FILE")

if ! ps -p "$pid" > /dev/null 2>&1; then
  echo "[ERROR] Process $pid not found" >&2
  rm -f "$PID_FILE"
  exit 1
fi

echo "[INFO] Stopping server (PID: $pid)..."
kill -TERM "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true

rm -f "$PID_FILE"
echo "[SUCCESS] Server stopped"
SCRIPT_EOF
}

# Function to generate start.bat script
generate_start_script_bat() {
  local script_path="$1"
  cat > "$script_path" << 'SCRIPT_EOF'
@echo off
REM start.bat - Start Kaiten MCP server on Windows

setlocal enabledelayedexpansion

set APP_DIR=%~dp0..
set JAR_FILE=%APP_DIR%\lib\kaiten-mcp.jar
set SERVER_PORT=8080
if not "%SERVER_PORT%"=="" goto skip_port_env
set SERVER_PORT=8080
:skip_port_env

if not exist "%JAR_FILE%" (
    echo [ERROR] JAR file not found: %JAR_FILE%
    exit /b 1
)

echo [INFO] Starting Kaiten MCP server on port %SERVER_PORT%...

REM Determine which JRE to use
if exist "%APP_DIR%\jre\bin\java.exe" (
    set JAVA=%APP_DIR%\jre\bin\java.exe
) else (
    set JAVA=java.exe
)

REM Start server (Windows doesn't have nohup, use separate window)
start "Kaiten MCP Server" %JAVA% -jar "%JAR_FILE%"

echo [SUCCESS] Server started
timeout /t 2 /nobreak

REM Try to open browser
start http://localhost:%SERVER_PORT%

echo [INFO] UI available at http://localhost:%SERVER_PORT%
SCRIPT_EOF
}

# Function to generate stop.bat script
generate_stop_script_bat() {
  local script_path="$1"
  cat > "$script_path" << 'SCRIPT_EOF'
@echo off
REM stop.bat - Stop Kaiten MCP server on Windows

echo [INFO] Stopping Kaiten MCP server...
taskkill /F /IM java.exe /C kaiten-mcp
echo [SUCCESS] Server stopped (if running)
SCRIPT_EOF
}

# Function to create zip package
create_zip_package() {
  log_info "Creating distribution package..."
  
  if [ ! -d "$APP_DIR" ]; then
    log_error "Package directory not found: $APP_DIR"
    return 1
  fi
  
  cd "$OUT_DIR"
  
  # Remove existing zip
  if [ -f "kaiten-mcp.zip" ]; then
    rm -f "kaiten-mcp.zip"
  fi
  
  # Create zip
  if command -v zip &> /dev/null; then
    zip -r -q "kaiten-mcp.zip" "kaiten-mcp/"
  else
    log_warn "zip command not found, trying tar instead"
    tar -czf "kaiten-mcp.tar.gz" "kaiten-mcp/"
    log_success "Created: kaiten-mcp.tar.gz"
    return 0
  fi
  
  log_success "Created distribution package: kaiten-mcp.zip"
  
  # Show package size
  local size
  size=$(du -sh "kaiten-mcp.zip" | cut -f1)
  log_info "Package size: $size"
}

# Function to validate package
validate_package() {
  log_info "Validating package..."
  
  local missing=0
  
  # Check required files
  for file in "lib/kaiten-mcp.jar" "bin/start.sh" "bin/stop.sh" "static/index.html" "VERSION"; do
    if [ ! -f "$APP_DIR/$file" ]; then
      log_error "Missing: $file"
      missing=$((missing + 1))
    fi
  done
  
  # Check directories
  for dir in "bin" "lib" "static"; do
    if [ ! -d "$APP_DIR/$dir" ]; then
      log_error "Missing directory: $dir"
      missing=$((missing + 1))
    fi
  done
  
  if [ $missing -gt 0 ]; then
    log_error "Package validation failed: $missing missing items"
    return 1
  fi
  
  log_success "Package validation passed"
}

# Main workflow
main() {
  log_info "========================================="
  log_info "Kaiten MCP Unified Build"
  log_info "========================================="
  log_info "Project root: $PROJECT_ROOT"
  log_info "Output directory: $OUT_DIR"
  log_info "Skip JRE: $SKIP_JRE"
  log_info "Skip UI: $SKIP_UI"
  log_info "Skip Backend: $SKIP_BACKEND"
  log_info "========================================="
  
  # Build UI
  if [ "$SKIP_UI" != "true" ]; then
    build_ui
  else
    log_warn "UI build skipped (--skip-ui flag)"
  fi
  
  # Build backend
  if [ "$SKIP_BACKEND" != "true" ]; then
    build_backend
  else
    log_warn "Backend build skipped (--skip-backend flag)"
  fi
  
  # Prepare JRE
  prepare_jre
  
  # Assemble package
  assemble_package
  
  # Validate
  validate_package
  
  # Create zip
  create_zip_package
  
  log_info "========================================="
  log_success "Build completed successfully!"
  log_info "========================================="
  log_info "Package location: $OUT_DIR/kaiten-mcp.zip"
  log_info "Package directory: $APP_DIR"
  log_info ""
  log_info "To start the server:"
  log_info "  cd $APP_DIR && ./bin/start.sh"
}

main "$@"
