#!/usr/bin/env bash
set -euo pipefail

# scripts/check-env.sh
# Проверяет локальные версии Java, Node.js и npm и рекомендует корректировать через sdkman / nvm

REQUIRED_JAVA_MAJOR=21
REQUIRED_NODE_MAJOR=16
REQUIRED_NPM_MAJOR=8

error=0

echo "Checking local environment versions..."

# Check Java
if command -v java >/dev/null 2>&1; then
  java_version_str=$(java -version 2>&1 | head -n 1)
  # Example: openjdk version "21.0.1" 2023-09-19
  java_major=$(echo "$java_version_str" | sed -n 's/.*[^0-9]\([0-9]\+\)\..*/\1/p') || true
  echo "Java: $java_version_str (major: $java_major)"
  if [ -z "$java_major" ] || [ "$java_major" -lt "$REQUIRED_JAVA_MAJOR" ]; then
    echo "ERROR: Java version mismatch. Required: $REQUIRED_JAVA_MAJOR+, found: $java_major"
    echo "Use sdkman to install/switch: https://sdkman.io/"
    echo "  example: sdk install java 21.0.0-open && sdk use java 21.0.0-open"
    error=1
  fi
else
  echo "ERROR: java not found in PATH"
  echo "Install via sdkman: https://sdkman.io/"
  error=1
fi

# Check Node
if command -v node >/dev/null 2>&1; then
  node_version=$(node -v) # v16.20.0
  node_major=$(echo "$node_version" | sed -n 's/^v\([0-9]\+\).*/\1/p')
  echo "Node: $node_version"
  if [ -z "$node_major" ] || [ "$node_major" -lt "$REQUIRED_NODE_MAJOR" ]; then
    echo "ERROR: Node version mismatch. Required: $REQUIRED_NODE_MAJOR+, found: $node_major"
    echo "Use nvm to install/switch: https://github.com/nvm-sh/nvm"
    echo "  example: nvm install 16 && nvm use 16"
    error=1
  fi
else
  echo "ERROR: node not found in PATH"
  echo "Install via nvm: https://github.com/nvm-sh/nvm"
  error=1
fi

# Check npm
if command -v npm >/dev/null 2>&1; then
  npm_version=$(npm -v)
  npm_major=$(echo "$npm_version" | sed -n 's/^\([0-9]\+\).*/\1/p')
  echo "npm: $npm_version"
  if [ -z "$npm_major" ] || [ "$npm_major" -lt "$REQUIRED_NPM_MAJOR" ]; then
    echo "ERROR: npm version mismatch. Required: $REQUIRED_NPM_MAJOR+, found: $npm_major"
    echo "Try: npm install -g npm@${REQUIRED_NPM_MAJOR} (if appropriate)"
    error=1
  fi
else
  echo "ERROR: npm not found in PATH (required for UI development)"
  error=1
fi

if [ "$error" -ne 0 ]; then
  echo
  echo "One or more environment checks failed. Follow the suggestions above to fix your environment."
  exit 1
else
  echo "Environment looks good."
  exit 0
fi