#!/usr/bin/env bash
#
# OpenCode Offline Installer (Linux x64)
# Installs OpenCode with bundled Node.js runtime for fully offline usage
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${OPENCODE_INSTALL_DIR:-$HOME/.opencode}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/opencode"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

log()      { echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"; }
log_sub()  { echo -e "    ${GREEN}->${NC} $1"; }
log_warn() { echo -e "    ${YELLOW}[WARN]${NC} $1"; }
die()      { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo -e "\n${BOLD}OpenCode Offline Installer${NC}\n"

log "Checking system"
[[ "$(uname -m)" != "x86_64" ]] && die "Requires Linux x86_64 (detected: $(uname -m))"
[[ "$(uname -s)" != "Linux" ]] && die "Requires Linux (detected: $(uname -s))"
[[ ! -f "$SCRIPT_DIR/bin/opencode" ]] && die "Bundle incomplete: missing bin/opencode"
[[ ! -f "$SCRIPT_DIR/cache/api.json" ]] && die "Bundle incomplete: missing cache/api.json"
[[ ! -d "$SCRIPT_DIR/deps/node_modules" ]] && die "Bundle incomplete: missing deps/node_modules"
node_archive=$(find "$SCRIPT_DIR/node" -name "node-*.tar.xz" 2>/dev/null | head -1)
[[ -z "$node_archive" ]] && die "Bundle incomplete: missing Node.js archive"
log_sub "System OK"

log "Creating directories"
mkdir -p "$INSTALL_DIR"/{bin,node,cache} "$CONFIG_DIR" "$CACHE_DIR"

log "Installing OpenCode"
cp "$SCRIPT_DIR/bin/opencode" "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/opencode"
log_sub "Version: $("$INSTALL_DIR/bin/opencode" --version 2>/dev/null || echo "unknown")"

log "Installing Node.js"
tar -xJf "$node_archive" -C "$INSTALL_DIR/node" --strip-components=1
log_sub "Version: $("$INSTALL_DIR/node/bin/node" --version 2>/dev/null || echo "unknown")"

log "Installing models cache"
cp "$SCRIPT_DIR/cache/api.json" "$INSTALL_DIR/cache/"

log "Installing dependencies"
for dest in "$CACHE_DIR" "$CONFIG_DIR"; do
    cp "$SCRIPT_DIR/deps/package.json" "$dest/"
    rm -rf "$dest/node_modules"
    cp -r "$SCRIPT_DIR/deps/node_modules" "$dest/"
done

log "Installing agents and skills"
if [[ -d "$SCRIPT_DIR/config/agents" ]]; then
    mkdir -p "$CONFIG_DIR/agents"
    cp -r "$SCRIPT_DIR/config/agents/"* "$CONFIG_DIR/agents/"
    log_sub "$(find "$CONFIG_DIR/agents" -name "*.md" 2>/dev/null | wc -l) agents"
fi
if [[ -d "$SCRIPT_DIR/config/skills" ]]; then
    mkdir -p "$CONFIG_DIR/skills"
    cp -r "$SCRIPT_DIR/config/skills/"* "$CONFIG_DIR/skills/"
    log_sub "$(find "$CONFIG_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l) skills"
fi
[[ -f "$SCRIPT_DIR/config/AGENTS.md.template" ]] && cp "$SCRIPT_DIR/config/AGENTS.md.template" "$CONFIG_DIR/"

log "Installing configuration"
if [[ -f "$CONFIG_DIR/opencode.json" ]]; then
    backup="$CONFIG_DIR/opencode.json.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_DIR/opencode.json" "$backup"
    log_sub "Backed up existing config"
    log_warn "Edit config manually to update"
else
    cp "$SCRIPT_DIR/opencode.json.example" "$CONFIG_DIR/opencode.json"
    log_sub "Installed sample config"
    log_warn "Edit $CONFIG_DIR/opencode.json with your LLM endpoint"
fi

log "Configuring shell"
env_block="
# OpenCode Offline Environment
export PATH=\"$INSTALL_DIR/node/bin:$INSTALL_DIR/bin:\$PATH\"
export OPENCODE_MODELS_URL=\"file://$INSTALL_DIR/cache/api.json\""

case "${SHELL:-/bin/bash}" in
    */zsh)  shell_rc="${ZDOTDIR:-$HOME}/.zshrc" ;;
    */bash) shell_rc="$HOME/.bashrc" ;;
    *)      shell_rc="$HOME/.profile" ;;
esac

if grep -q "# OpenCode Offline Environment" "$shell_rc" 2>/dev/null; then
    tmp=$(mktemp)
    sed '/# OpenCode Offline Environment/,/^export OPENCODE_MODELS_URL/d' "$shell_rc" > "$tmp"
    echo "$env_block" >> "$tmp"
    mv "$tmp" "$shell_rc"
    log_sub "Updated $shell_rc"
else
    echo "$env_block" >> "$shell_rc"
    log_sub "Added to $shell_rc"
fi

if [[ -f "$HOME/.zshrc" && "$shell_rc" != "$HOME/.zshrc" ]]; then
    if ! grep -q "# OpenCode Offline Environment" "$HOME/.zshrc" 2>/dev/null; then
        echo "$env_block" >> "$HOME/.zshrc"
        log_sub "Also added to ~/.zshrc"
    fi
fi

echo -e "\n${GREEN}${BOLD}Installation complete!${NC}\n"
cat << EOF
Paths:
  Binary:  $INSTALL_DIR/bin/opencode
  Config:  $CONFIG_DIR/opencode.json
  Agents:  $CONFIG_DIR/agents/

Environment:
  OPENCODE_MODELS_URL=file://$INSTALL_DIR/cache/api.json

EOF

log_warn "Configure your LLM endpoint:"
echo "  nano $CONFIG_DIR/opencode.json"
echo ""
echo "  baseURL examples:"
echo "    Ollama:    http://localhost:11434/v1"
echo "    vLLM:      http://your-server:8000/v1"
echo "    LM Studio: http://localhost:1234/v1"
echo ""

log "Get started:"
echo "  source ~/.bashrc"
echo "  cd your-project && opencode"
echo "  /init"
echo ""
