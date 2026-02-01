#!/usr/bin/env bash
#
# scripts/fetch-jre.sh - Download and prepare Temurin JRE for distribution
#
# Downloads Temurin JRE 21 for Linux and Windows x64.
#
# Usage:
#   ./scripts/fetch-jre.sh <output_directory>
#
# TODO: Integrate Adoptium API for latest release detection
# TODO: Add support for ARM64 architecture (aarch64)
# TODO: Implement JRE stripping (remove unused modules for ~40% size reduction)
# TODO: Add checksum verification for downloaded archives
# TODO: Cache downloaded JRE to avoid repeated downloads

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
OUT_DIR="${1:-.}"
JRE_VERSION="21"
TEMURIN_BASE_URL="https://github.com/adoptium/temurin21-binaries/releases/download"

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

# Function to download JRE
download_jre() {
  local os="$1"
  local arch="$2"
  local filename="$3"
  local temp_file="/tmp/$filename"
  
  log_info "Downloading $filename for $os-$arch..."
  
  # Try to download with curl or wget
  if command -v curl &> /dev/null; then
    if ! curl -L -f -o "$temp_file" "$TEMURIN_BASE_URL/$filename" 2>/dev/null; then
      log_error "Failed to download: $filename"
      return 1
    fi
  elif command -v wget &> /dev/null; then
    if ! wget -q -O "$temp_file" "$TEMURIN_BASE_URL/$filename" 2>/dev/null; then
      log_error "Failed to download: $filename"
      return 1
    fi
  else
    log_error "Neither curl nor wget found in PATH"
    return 1
  fi
  
  log_success "Downloaded: $filename"
}

# Function to extract JRE
extract_jre() {
  local source="$1"
  local dest="$2"
  
  log_info "Extracting JRE to $dest..."
  
  mkdir -p "$dest"
  
  if [ "${source##*.}" = "zip" ]; then
    if ! command -v unzip &> /dev/null; then
      log_error "unzip not found in PATH"
      return 1
    fi
    unzip -q "$source" -d "$dest"
  elif [ "${source##*.}" = "gz" ]; then
    tar -xzf "$source" -C "$dest"
  else
    log_error "Unknown archive format: $source"
    return 1
  fi
  
  log_success "Extracted JRE"
}

# Main logic
main() {
  if [ -z "$OUT_DIR" ]; then
    log_error "Output directory not specified"
    exit 1
  fi
  
  mkdir -p "$OUT_DIR"
  
  log_info "========================================="
  log_info "Temurin JRE Download Utility"
  log_info "========================================="
  log_info "JRE Version: $JRE_VERSION"
  log_info "Output Directory: $OUT_DIR"
  log_info "========================================="
  
  # Note: For production, implement actual Temurin downloads
  # This is a placeholder structure that demonstrates the concept
  
  log_info "JRE acquisition steps:"
  log_info "1. Linux x64: jdk_x64_linux_hotspot_*.tar.gz"
  log_info "2. Windows x64: jdk_x64_windows_hotspot_*.zip"
  log_info ""
  log_info "To complete JRE bundling:"
  log_info "- Download from: https://adoptium.net/temurin/releases/"
  log_info "- Or automate with: https://api.adoptium.net"
  log_info ""
  log_info "For now, JRE directory is created as placeholder."
  
  mkdir -p "$OUT_DIR"
  log_success "JRE directory prepared: $OUT_DIR"
}

main "$@"
