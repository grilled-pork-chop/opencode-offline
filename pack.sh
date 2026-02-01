#!/usr/bin/env bash
#
# OpenCode Offline Packager
# Downloads OpenCode, Node.js, and dependencies for offline installation (Linux x64 only)
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
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "${BLUE}[STEP]${NC} $1"; }

# URLs
OPENCODE_URL="https://github.com/sst/opencode/releases/latest/download/opencode-linux-x64.tar.gz"
NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz"
MODELS_API_URL="https://models.dev/api.json"

# Dependencies to include (OpenCode auth plugins + AI SDK)
OPENCODE_DEPS=(
    "@ai-sdk/openai-compatible@latest"
    "@opencode-ai/plugin@latest"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 OpenCode Offline Packager                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    for cmd in curl tar npm; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    cleanup
    
    log_step "Creating directory structure..."
    mkdir -p "$BUNDLE_DIR"/{bin,node,deps,config}
    
    # =========================================================================
    # 1. Download OpenCode binary
    # =========================================================================
    log_step "Downloading OpenCode binary..."
    local tmp_tar=$(mktemp)
    download_file "$OPENCODE_URL" "$tmp_tar"
    tar -xzf "$tmp_tar" -C "$BUNDLE_DIR/bin"
    rm "$tmp_tar"
    chmod +x "$BUNDLE_DIR/bin/opencode"
    log_info "OpenCode binary ready"
    
    # =========================================================================
    # 2. Download Node.js
    # =========================================================================
    log_step "Downloading Node.js ${NODE_VERSION}..."
    local node_archive="$BUNDLE_DIR/node/node-${NODE_VERSION}-linux-x64.tar.xz"
    download_file "$NODE_URL" "$node_archive"
    log_info "Node.js archive ready"
    
    # =========================================================================
    # 3. Download models.dev API cache
    # =========================================================================
    log_step "Downloading models.dev API cache..."
    download_file "$MODELS_API_URL" "$BUNDLE_DIR/config/api.json"
    log_info "Models API cache ready"
    
    # =========================================================================
    # 4. Install OpenCode dependencies
    # =========================================================================
    log_step "Installing OpenCode dependencies..."
    mkdir -p "$BUNDLE_DIR/deps/opencode"
    pushd "$BUNDLE_DIR/deps/opencode" > /dev/null
    
    cat > package.json << 'EOF'
{
  "name": "opencode-deps",
  "private": true,
  "dependencies": {}
}
EOF
    
    npm install --no-bin-links --ignore-scripts --no-audit --no-fund \
    "${OPENCODE_DEPS[@]}" 2>&1 | grep -E '(added|npm warn)' || true
    popd > /dev/null
    log_info "OpenCode dependencies installed"

    # =========================================================================
    # 5. Copy configuration template
    # =========================================================================
    log_step "Copying configuration template..."
    
    if [[ -d "$SCRIPT_DIR/templates" ]]; then
        cp "$SCRIPT_DIR/templates/opencode.json" "$BUNDLE_DIR/config/"
        log_info "Copied configuration template"
    else
        log_error "templates/ folder not found in $SCRIPT_DIR"
        exit 1
    fi
    
    # =========================================================================
    # 6. Copy CLI and documentation
    # =========================================================================
    log_step "Adding CLI and documentation..."
    
    if [[ -f "$SCRIPT_DIR/opencode-offline" ]]; then
        cp "$SCRIPT_DIR/opencode-offline" "$BUNDLE_DIR/"
        chmod +x "$BUNDLE_DIR/opencode-offline"
        log_info "Added opencode-offline CLI"
    else
        log_error "opencode-offline not found in $SCRIPT_DIR"
        exit 1
    fi
    
    if [[ -f "$SCRIPT_DIR/USAGE.md" ]]; then
        cp "$SCRIPT_DIR/USAGE.md" "$BUNDLE_DIR/README.md"
        log_info "Added README into the bundle"
    fi
    
    # =========================================================================
    # 7. Create archive
    # =========================================================================
    log_step "Creating archive..."
    tar -czf "$OUTPUT_ARCHIVE" -C "$BUNDLE_DIR" .
    
    rm -rf "$BUNDLE_DIR"
    
    local size=$(du -h "$OUTPUT_ARCHIVE" | cut -f1)
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      BUILD COMPLETE                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Created: $OUTPUT_ARCHIVE ($size)"
    echo ""
    echo "Contents:"
    echo "  • OpenCode binary (Linux x64)"
    echo "  • Node.js ${NODE_VERSION}"
    echo "  • @ai-sdk/openai-compatible"
    echo "  • Configuration template"
    echo "  • models.dev API cache"
    echo ""
    echo "To install on target machine:"
    echo "  1. Copy $OUTPUT_ARCHIVE to target"
    echo "  2. tar -xzf $OUTPUT_ARCHIVE"
    echo "  3. ./opencode-offline install"
    echo ""
}

main "$@"