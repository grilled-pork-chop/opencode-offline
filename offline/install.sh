#!/usr/bin/env bash
#
# OpenCode Offline Installer (Linux x64)
# Run this script after extracting the offline bundle
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${OPENCODE_INSTALL_DIR:-$HOME/.opencode}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/opencode"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode"

main() {
    log_info "=== OpenCode Offline Installer ==="
    
    # Verify architecture
    if [[ "$(uname -m)" != "x86_64" ]]; then
        log_error "This package is for Linux x64 only (detected: $(uname -m))"
    fi
    
    # Create directories
    mkdir -p "$INSTALL_DIR/bin" "$INSTALL_DIR/node" "$CACHE_DIR" "$CONFIG_DIR" "$DATA_DIR"
    
    # Install OpenCode binary
    log_info "Installing OpenCode binary..."
    cp "$SCRIPT_DIR/bin/opencode" "$INSTALL_DIR/bin/"
    chmod +x "$INSTALL_DIR/bin/opencode"
    
    # Extract Node.js
    log_info "Extracting Node.js..."
    local node_archive=$(find "$SCRIPT_DIR/node" -name "node-*.tar.xz" | head -1)
    if [[ -z "$node_archive" ]]; then
        log_error "Node.js archive not found"
    fi
    tar -xJf "$node_archive" -C "$INSTALL_DIR/node" --strip-components=1
    
    # Install models.dev cache (critical for offline startup)
    log_info "Installing models cache..."
    if [[ -f "$SCRIPT_DIR/cache/models.json" ]]; then
        cp "$SCRIPT_DIR/cache/models.json" "$CACHE_DIR/models.json"
        log_info "Models cache installed to $CACHE_DIR/models.json"
    else
        log_warn "models.json not found - OpenCode may hang on startup"
    fi
    
    # Install dependencies to cache and config directories
    log_info "Installing dependencies..."
    for dest in "$CACHE_DIR" "$CONFIG_DIR"; do
        cp "$SCRIPT_DIR/deps/package.json" "$dest/"
        rm -rf "$dest/node_modules"
        cp -r "$SCRIPT_DIR/deps/node_modules" "$dest/"
    done
    
    # Install sample config if no config exists
    if [[ ! -f "$CONFIG_DIR/opencode.json" ]]; then
        log_info "Installing sample config..."
        cp "$SCRIPT_DIR/opencode.json.example" "$CONFIG_DIR/opencode.json"
        log_warn "Edit $CONFIG_DIR/opencode.json with your LLM endpoint!"
    fi
    
    # Setup PATH in shell config
    setup_path
    
    log_info "=== Installation Complete ==="
    echo ""
    echo "OpenCode installed to: $INSTALL_DIR"
    echo "Config file: $CONFIG_DIR/opencode.json"
    echo ""
    echo "IMPORTANT: Edit your config file to set your LLM endpoint:"
    echo "  nano $CONFIG_DIR/opencode.json"
    echo ""
    echo "Then start using OpenCode:"
    echo "  source ~/.bashrc  # or restart your terminal"
    echo "  cd your-project"
    echo "  opencode"
}

setup_path() {
    local bin_path="$INSTALL_DIR/bin"
    local node_path="$INSTALL_DIR/node/bin"
    local export_line="export PATH=\"$node_path:$bin_path:\$PATH\""
    
    # Determine shell config file
    local config_file=""
    case "${SHELL:-/bin/bash}" in
        */zsh)  config_file="${ZDOTDIR:-$HOME}/.zshrc" ;;
        */bash) config_file="$HOME/.bashrc" ;;
        *)      config_file="$HOME/.profile" ;;
    esac
    
    # Check if already in PATH
    if [[ ":$PATH:" == *":$bin_path:"* ]]; then
        log_info "PATH already configured"
        return
    fi
    
    # Add to shell config
    if [[ -f "$config_file" ]]; then
        # Remove old entries
        sed -i '/# OpenCode PATH/d' "$config_file" 2>/dev/null || true
        sed -i '/opencode.*node\/bin/d' "$config_file" 2>/dev/null || true
        
        # Add new entry
        {
            echo ""
            echo "# OpenCode PATH"
            echo "$export_line"
        } >> "$config_file"
        
        log_info "Added to PATH in $config_file"
        log_warn "Run 'source $config_file' or restart your terminal"
    else
        log_warn "Could not find shell config. Add manually:"
        echo "  $export_line"
    fi
}

main "$@"