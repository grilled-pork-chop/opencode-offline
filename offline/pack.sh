#!/usr/bin/env bash
#
# OpenCode Offline Packager
# Downloads opencode, Node.js, dependencies, and models cache for offline installation (Linux x64 only)
#
set -euo pipefail

# Configuration
NODE_VERSION="v22.16.0"
BUNDLE_DIR="opencode-offline-bundle"
OUTPUT_ARCHIVE="opencode-offline.tar.gz"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# URLs
OPENCODE_URL="https://github.com/anomalyco/opencode/releases/latest/download/opencode-linux-x64.tar.gz"
NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz"
MODELS_URL="https://models.dev/api.json"

# Dependencies to include
DEPS_PACKAGES=(
    "@opencode-ai/plugin@latest"
    "opencode-anthropic-auth@latest"
    "@openauthjs/openauth@latest"
    "@gitlab/opencode-gitlab-auth@latest"
)

cleanup() {
    log_info "Cleaning previous build..."
    rm -rf "$BUNDLE_DIR" "$OUTPUT_ARCHIVE"
}

download_file() {
    local url=$1
    local dest=$2
    log_info "Downloading $(basename "$dest")..."
    curl -fSL --progress-bar -o "$dest" "$url"
}

main() {
    log_info "=== OpenCode Offline Packager ==="
    
    # Check requirements
    for cmd in curl tar npm; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    cleanup
    
    # Create directory structure
    log_info "Creating directory structure..."
    mkdir -p "$BUNDLE_DIR"/{bin,node,deps,cache}
    
    # Download OpenCode binary
    log_info "Downloading OpenCode..."
    local tmp_tar=$(mktemp)
    download_file "$OPENCODE_URL" "$tmp_tar"
    tar -xzf "$tmp_tar" -C "$BUNDLE_DIR/bin"
    rm "$tmp_tar"
    chmod +x "$BUNDLE_DIR/bin/opencode"
    log_info "OpenCode binary ready"
    
    # Download Node.js
    log_info "Downloading Node.js ${NODE_VERSION}..."
    local node_archive="$BUNDLE_DIR/node/node-${NODE_VERSION}-linux-x64.tar.xz"
    download_file "$NODE_URL" "$node_archive"
    log_info "Node.js archive ready"
    
    # Download models.dev data (critical for offline use)
    log_info "Downloading models.dev cache..."
    download_file "$MODELS_URL" "$BUNDLE_DIR/cache/models.json"
    log_info "Models cache ready"
    
    # Install dependencies
    log_info "Installing npm dependencies..."
    cat > "$BUNDLE_DIR/deps/package.json" << 'EOF'
{
  "name": "opencode-offline-deps",
  "private": true,
  "dependencies": {}
}
EOF
    
    pushd "$BUNDLE_DIR/deps" > /dev/null
    npm init -y > /dev/null 2>&1
    npm install --no-bin-links --ignore-scripts --no-audit --no-fund \
        "${DEPS_PACKAGES[@]}" 2>&1 | grep -E '(added|npm warn)' || true
    popd > /dev/null
    log_info "Dependencies installed"
    
    # Create sample config for offline use
    log_info "Creating sample config..."
    cat > "$BUNDLE_DIR/opencode.json.example" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "provider": {
    "my_provider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My Private LLM",
      "options": {
        "baseURL": "http://your-llm-server:8080/v1",
        "apiKey": "your-api-key"
      },
      "models": {
        "your-model-id": {
          "name": "Your Model Name",
          "attachment": false,
          "reasoning": false
        }
      }
    }
  },
  "model": "my_provider/your-model-id"
}
EOF
    
    # Copy install script
    log_info "Adding install script..."
    cp "$(dirname "$0")/install.sh" "$BUNDLE_DIR/"
    chmod +x "$BUNDLE_DIR/install.sh"
    
    # Create archive
    log_info "Creating archive..."
    tar -czf "$OUTPUT_ARCHIVE" -C "$BUNDLE_DIR" .
    
    # Cleanup build directory
    rm -rf "$BUNDLE_DIR"
    
    local size=$(du -h "$OUTPUT_ARCHIVE" | cut -f1)
    log_info "=== Done ==="
    log_info "Created: $OUTPUT_ARCHIVE ($size)"
    echo ""
    echo "To install on target machine:"
    echo "  1. Copy $OUTPUT_ARCHIVE to target"
    echo "  2. tar -xzf $OUTPUT_ARCHIVE"
    echo "  3. ./install.sh"
    echo "  4. Edit ~/.config/opencode/opencode.json with your LLM endpoint"
}

main "$@"