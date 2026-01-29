#!/usr/bin/env bash
#
# OpenCode Offline Packager with oh-my-opencode
# Downloads opencode, Node.js, oh-my-opencode plugin, and dependencies
# For offline installation (Linux x64 only)
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

# oh-my-opencode plugin
OH_MY_OPENCODE_DEPS=(
    "oh-my-opencode@latest"
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
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     OpenCode Offline Packager (with oh-my-opencode)          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check requirements
    for cmd in curl tar npm; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    cleanup
    
    # Create directory structure
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
    # 5. Install oh-my-opencode plugin
    # =========================================================================
    log_step "Installing oh-my-opencode plugin..."
    mkdir -p "$BUNDLE_DIR/deps/plugin"
    pushd "$BUNDLE_DIR/deps/plugin" > /dev/null
    
    cat > package.json << 'EOF'
{
  "name": "opencode-plugin",
  "private": true,
  "dependencies": {}
}
EOF
    
    npm install --no-bin-links --ignore-scripts --no-audit --no-fund \
        "${OH_MY_OPENCODE_DEPS[@]}" 2>&1 | grep -E '(added|npm warn)' || true
    popd > /dev/null
    log_info "oh-my-opencode plugin installed"
    
    # =========================================================================
    # 6. Generate configuration files
    # =========================================================================
    log_step "Generating configuration files..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy config templates from templates/ folder
    if [[ -d "$script_dir/templates" ]]; then
        cp "$script_dir/templates/opencode.json" "$BUNDLE_DIR/config/"
        cp "$script_dir/templates/oh-my-opencode.json" "$BUNDLE_DIR/config/"
        log_info "Copied configuration templates"
    else
        log_error "templates/ folder not found in $script_dir"
        exit 1
    fi
    
    # =========================================================================
    # 7. Copy install script
    # =========================================================================
    log_step "Adding install script..."
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [[ -f "$script_dir/install.sh" ]]; then
        cp "$script_dir/install.sh" "$BUNDLE_DIR/"
    else
        log_error "install.sh not found in $script_dir"
        exit 1
    fi
    chmod +x "$BUNDLE_DIR/install.sh"
    
    # =========================================================================
    # 8. Create archive
    # =========================================================================
    log_step "Creating archive..."
    tar -czf "$OUTPUT_ARCHIVE" -C "$BUNDLE_DIR" .
    
    # Cleanup build directory
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
    echo "  • oh-my-opencode plugin"
    echo "  • @ai-sdk/openai-compatible"
    echo "  • Configuration files (offline agents)"
    echo "  • models.dev API cache"
    echo ""
    echo "To install on target machine:"
    echo "  1. Copy $OUTPUT_ARCHIVE to target"
    echo "  2. tar -xzf $OUTPUT_ARCHIVE"
    echo "  3. ./install.sh"
    echo ""
}

main "$@"