#!/usr/bin/env bash
#
# OpenCode Offline Installer with oh-my-opencode
# Installs OpenCode, Node.js, oh-my-opencode plugin from pre-packaged bundle
#
set -euo pipefail

# Installation paths
INSTALL_BASE="$HOME/.opencode"
CONFIG_DIR="$HOME/.config/opencode"
CACHE_DIR="$HOME/.opencode/cache"
NODE_VERSION="v22.16.0"

# Default provider settings
DEFAULT_PROVIDER_URL="http://localhost:8000/v1"
DEFAULT_MODEL_NAME="deepseek-v32"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()  { echo -e "${BLUE}[STEP]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROVIDER_URL=""
MODEL_NAME=""

configure_provider() {
    echo ""
    log_step "Provider Configuration"
    echo ""
    echo "Configure your LLM provider (OpenAI-compatible API)."
    echo ""
    echo "URL examples:"
    echo "  • Ollama:      http://localhost:11434/v1"
    echo "  • LM Studio:   http://localhost:1234/v1"
    echo "  • vLLM:        http://localhost:8000/v1"
    echo "  • Text Gen UI: http://localhost:5000/v1"
    echo "  • Custom:      http://your-server:port/v1"
    echo ""
    
    read -p "Provider URL [${DEFAULT_PROVIDER_URL}]: " input_url
    PROVIDER_URL="${input_url:-$DEFAULT_PROVIDER_URL}"
    
    echo ""
    echo "Model examples:"
    echo "  • qwen3-coder:30b      (Ollama - recommended)"
    echo "  • devstral-small-2:24b (Ollama)"
    echo "  • deepseek-v32         (vLLM/other)"
    echo ""
    
    read -p "Model name [${DEFAULT_MODEL_NAME}]: " input_model
    MODEL_NAME="${input_model:-$DEFAULT_MODEL_NAME}"
    
    echo ""
    log_info "URL:   ${CYAN}${PROVIDER_URL}${NC}"
    log_info "Model: ${CYAN}${MODEL_NAME}${NC}"
    echo ""
}

install_node() {
    log_step "Installing Node.js..."
    
    local node_archive="$SCRIPT_DIR/node/node-${NODE_VERSION}-linux-x64.tar.xz"
    
    if [[ ! -f "$node_archive" ]]; then
        log_error "Node.js archive not found: $node_archive"
        exit 1
    fi
    
    mkdir -p "$INSTALL_BASE/node"
    tar -xJf "$node_archive" -C "$INSTALL_BASE/node" --strip-components=1
    
    log_info "Node.js installed to $INSTALL_BASE/node"
}

install_opencode() {
    log_step "Installing OpenCode binary..."
    
    local binary="$SCRIPT_DIR/bin/opencode"
    
    if [[ ! -f "$binary" ]]; then
        log_error "OpenCode binary not found: $binary"
        exit 1
    fi
    
    mkdir -p "$INSTALL_BASE/bin"
    cp "$binary" "$INSTALL_BASE/bin/"
    chmod +x "$INSTALL_BASE/bin/opencode"
    
    log_info "OpenCode installed to $INSTALL_BASE/bin/opencode"
}

install_dependencies() {
    log_step "Installing npm dependencies..."
    
    # OpenCode dependencies go to ~/.opencode/cache/node_modules
    if [[ -d "$SCRIPT_DIR/deps/opencode/node_modules" ]]; then
        mkdir -p "$CACHE_DIR"
        cp -r "$SCRIPT_DIR/deps/opencode/node_modules" "$CACHE_DIR/"
        cp "$SCRIPT_DIR/deps/opencode/package.json" "$CACHE_DIR/"
        log_info "OpenCode dependencies installed to $CACHE_DIR/node_modules"
    fi
    
    # oh-my-opencode plugin goes to ~/.config/opencode/node_modules
    # This is where OpenCode looks for plugin dependencies
    if [[ -d "$SCRIPT_DIR/deps/plugin/node_modules" ]]; then
        mkdir -p "$CONFIG_DIR"
        cp -r "$SCRIPT_DIR/deps/plugin/node_modules" "$CONFIG_DIR/"
        cp "$SCRIPT_DIR/deps/plugin/package.json" "$CONFIG_DIR/"
        log_info "oh-my-opencode dependencies installed to $CONFIG_DIR/node_modules"
    fi
}

install_local_plugin() {
    log_step "Installing oh-my-opencode as local plugin..."
    
    # Create plugins directory for local plugins
    mkdir -p "$CONFIG_DIR/plugins"
    
    # Create a local plugin wrapper that imports from node_modules
    # This avoids the BunInstallFailedError because local plugins are loaded directly
    cat > "$CONFIG_DIR/plugins/oh-my-opencode-loader.js" << 'PLUGIN_EOF'
// oh-my-opencode local loader for offline use
// This wrapper loads oh-my-opencode from pre-installed node_modules
// avoiding the BunInstallFailedError in offline environments

import OhMyOpenCode from "oh-my-opencode";

// Re-export the plugin
export default OhMyOpenCode;

// Also export named exports if any
export * from "oh-my-opencode";
PLUGIN_EOF
    
    log_info "Created local plugin loader at $CONFIG_DIR/plugins/oh-my-opencode-loader.js"
}

install_config() {
    log_step "Installing configuration files..."
    
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$CACHE_DIR"
    
    if [[ -f "$SCRIPT_DIR/config/opencode.json" ]]; then
        if [[ -f "$CONFIG_DIR/opencode.json" ]]; then
            log_warn "Backing up existing opencode.json"
            cp "$CONFIG_DIR/opencode.json" "$CONFIG_DIR/opencode.json.bak"
        fi
        
        sed -e "s|__PROVIDER_URL__|${PROVIDER_URL}|g" \
            -e "s|__MODEL_NAME__|${MODEL_NAME}|g" \
            "$SCRIPT_DIR/config/opencode.json" > "$CONFIG_DIR/opencode.json"
        
        log_info "Installed opencode.json (URL: ${PROVIDER_URL}, model: ${MODEL_NAME})"
    else
        log_error "opencode.json not found in bundle!"
        exit 1
    fi
    
    if [[ -f "$SCRIPT_DIR/config/oh-my-opencode.json" ]]; then
        if [[ -f "$CONFIG_DIR/oh-my-opencode.json" ]]; then
            log_warn "Backing up existing oh-my-opencode.json"
            cp "$CONFIG_DIR/oh-my-opencode.json" "$CONFIG_DIR/oh-my-opencode.json.bak"
        fi
        
        sed "s|__MODEL_NAME__|${MODEL_NAME}|g" \
            "$SCRIPT_DIR/config/oh-my-opencode.json" > "$CONFIG_DIR/oh-my-opencode.json"
        
        log_info "Installed oh-my-opencode.json"
    else
        log_error "oh-my-opencode.json not found in bundle!"
        exit 1
    fi
    
    if [[ -f "$SCRIPT_DIR/config/api.json" ]]; then
        cp "$SCRIPT_DIR/config/api.json" "$CACHE_DIR/"
        log_info "Installed models API cache"
    else
        log_warn "api.json not found - OpenCode may try to fetch models online"
    fi
}

setup_environment() {
    log_step "Setting up environment..."
    
    local shell_rc=""
    local shell_name=""
    
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
        shell_name="zsh"
    elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
        shell_name="bash"
    fi
    
    local env_file="$INSTALL_BASE/env.sh"
    cat > "$env_file" << EOF
# OpenCode Offline Environment
export PATH="\$HOME/.opencode/bin:\$HOME/.opencode/node/bin:\$PATH"
export OPENCODE_MODELS_URL="file://\$HOME/.opencode/cache"
export NODE_PATH="\$HOME/.opencode/cache/node_modules:\$HOME/.config/opencode/node_modules"
EOF
    
    log_info "Created environment file: $env_file"
    
    if [[ -n "$shell_rc" ]] && [[ -f "$shell_rc" ]]; then
        local source_line="source \"\$HOME/.opencode/env.sh\""
        if ! grep -qF ".opencode/env.sh" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# OpenCode Offline" >> "$shell_rc"
            echo "$source_line" >> "$shell_rc"
            log_info "Added to $shell_rc"
        else
            log_info "Already in $shell_rc"
        fi
    fi
    
    export PATH="$INSTALL_BASE/bin:$INSTALL_BASE/node/bin:$PATH"
    export OPENCODE_MODELS_URL="file://$CACHE_DIR"
    export NODE_PATH="$CACHE_DIR/node_modules:$CONFIG_DIR/node_modules"
}

verify_installation() {
    log_step "Verifying installation..."
    
    local errors=0

    if [[ -x "$INSTALL_BASE/bin/opencode" ]]; then
        local version=$("$INSTALL_BASE/bin/opencode" --version 2>/dev/null || echo "unknown")
        log_info "OpenCode: $version ✓"
    else
        log_error "OpenCode binary not found"
        ((errors++))
    fi

    if [[ -x "$INSTALL_BASE/node/bin/node" ]]; then
        local node_ver=$("$INSTALL_BASE/node/bin/node" --version 2>/dev/null || echo "unknown")
        log_info "Node.js: $node_ver ✓"
    else
        log_error "Node.js not found"
        ((errors++))
    fi

    if [[ -d "$CONFIG_DIR/node_modules/oh-my-opencode" ]]; then
        log_info "oh-my-opencode module: installed ✓"
    else
        log_error "oh-my-opencode module not found"
        ((errors++))
    fi

    if [[ -f "$CONFIG_DIR/plugins/oh-my-opencode-loader.js" ]]; then
        log_info "oh-my-opencode local plugin: installed ✓"
    else
        log_error "oh-my-opencode local plugin not found"
        ((errors++))
    fi

    if [[ -f "$CONFIG_DIR/opencode.json" ]]; then
        log_info "opencode.json: present ✓"
    else
        log_warn "opencode.json not found"
    fi
    
    if [[ -f "$CONFIG_DIR/oh-my-opencode.json" ]]; then
        log_info "oh-my-opencode.json: present ✓"
    else
        log_warn "oh-my-opencode.json not found"
    fi

    if [[ -f "$CACHE_DIR/api.json" ]]; then
        log_info "Models API cache: present ✓"
    else
        log_warn "Models API cache not found"
    fi
    
    return $errors
}

print_summary() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              INSTALLATION COMPLETE                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Installation paths:"
    echo "  Binary:  $INSTALL_BASE/bin/opencode"
    echo "  Node.js: $INSTALL_BASE/node/"
    echo "  Config:  $CONFIG_DIR/"
    echo "  Cache:   $CACHE_DIR/"
    echo ""
    echo "Provider configuration:"
    echo "  URL:   ${PROVIDER_URL}"
    echo "  Model: ${MODEL_NAME}"
    echo ""
    echo "Installed components:"
    echo "  • OpenCode (Linux x64)"
    echo "  • Node.js ${NODE_VERSION}"
    echo "  • oh-my-opencode (as local plugin)"
    echo "  • @ai-sdk/openai-compatible (local provider)"
    echo ""
    echo "Configuration:"
    echo "  • opencode.json (local)"
    echo "  • oh-my-opencode.json (agent model overrides, disabled MCPs)"
    echo "  • plugins/oh-my-opencode-loader.js (local plugin loader)"
    echo ""
    echo "To activate in current shell:"
    echo "  source ~/.opencode/env.sh"
    echo ""
    echo "Then run:"
    echo "  opencode"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "IMPORTANT:"
    echo ""
    echo "  1. Ensure ${PROVIDER_URL} is running and accessible"
    echo "  2. Model '${MODEL_NAME}' must be available at that endpoint"
    echo "  3. Context window should be 32k+ for agents to work properly"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     OpenCode Offline Installer (with oh-my-opencode)         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    configure_provider

    install_node
    install_opencode
    install_dependencies
    install_local_plugin
    install_config
    setup_environment

    if verify_installation; then
        print_summary
    else
        echo ""
        log_error "Installation completed with errors"
        exit 1
    fi
}

main "$@"