#!/usr/bin/env bash
#
# OpenCode Offline Packager
# Creates a self-contained offline bundle for Linux x64
#
set -euo pipefail

NODE_VERSION="v22.16.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_DIR="opencode-offline-bundle"
OUTPUT="opencode-offline.tar.gz"
CONFIG_SRC="$SCRIPT_DIR/../opencode-config"

OPENCODE_URL="https://github.com/sst/opencode/releases/latest/download/opencode-linux-x64.tar.gz"
NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz"
MODELS_URL="https://models.dev/api.json"

PACKAGES=(
    "@ai-sdk/openai-compatible@latest"
    "@opencode-ai/plugin@latest"
    "opencode-anthropic-auth@latest"
    "@openauthjs/openauth@latest"
    "@gitlab/opencode-gitlab-auth@latest"
)

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

log()      { echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"; }
log_sub()  { echo -e "    ${GREEN}->${NC} $1"; }
log_warn() { echo -e "    ${YELLOW}[WARN]${NC} $1"; }
die()      { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

cleanup() {
    local code=$?
    [[ $code -ne 0 ]] && rm -rf "$BUNDLE_DIR" "$OUTPUT" 2>/dev/null
    exit $code
}
trap cleanup EXIT

for cmd in curl tar npm; do
    command -v "$cmd" &>/dev/null || die "Required command not found: $cmd"
done

echo -e "\n${BOLD}OpenCode Offline Packager${NC}\n"

log "Creating bundle structure"
rm -rf "$BUNDLE_DIR" "$OUTPUT"
mkdir -p "$BUNDLE_DIR"/{bin,node,deps,cache,config}

log "Downloading OpenCode"
tmp=$(mktemp)
curl -fSL --progress-bar -o "$tmp" "$OPENCODE_URL"
tar -xzf "$tmp" -C "$BUNDLE_DIR/bin"
rm "$tmp"

if [[ -f "$BUNDLE_DIR/bin/opencode" ]]; then
    chmod +x "$BUNDLE_DIR/bin/opencode"
elif [[ -d "$BUNDLE_DIR/bin/opencode-linux-x64" ]]; then
    mv "$BUNDLE_DIR/bin/opencode-linux-x64/opencode" "$BUNDLE_DIR/bin/"
    rm -rf "$BUNDLE_DIR/bin/opencode-linux-x64"
    chmod +x "$BUNDLE_DIR/bin/opencode"
else
    die "OpenCode binary not found after extraction"
fi
log_sub "Version: $("$BUNDLE_DIR/bin/opencode" --version 2>/dev/null || echo "unknown")"

log "Downloading Node.js ${NODE_VERSION}"
curl -fSL --progress-bar -o "$BUNDLE_DIR/node/node-${NODE_VERSION}-linux-x64.tar.xz" "$NODE_URL"

log "Downloading models cache"
curl -fSL --progress-bar -o "$BUNDLE_DIR/cache/api.json" "$MODELS_URL"

log "Installing npm packages"
cat > "$BUNDLE_DIR/deps/package.json" << 'EOF'
{"name":"opencode-offline-deps","version":"1.0.0","private":true}
EOF
pushd "$BUNDLE_DIR/deps" > /dev/null
npm install --no-bin-links --ignore-scripts --no-audit --no-fund "${PACKAGES[@]}" 2>&1 | tail -1
popd > /dev/null
log_sub "Installed $(find "$BUNDLE_DIR/deps/node_modules" -maxdepth 1 -type d | wc -l) packages"

log "Bundling agents and skills"
if [[ -d "$CONFIG_SRC" ]]; then
    [[ -d "$CONFIG_SRC/agents" ]] && cp -r "$CONFIG_SRC/agents" "$BUNDLE_DIR/config/" && \
        log_sub "$(find "$BUNDLE_DIR/config/agents" -name "*.md" | wc -l) agents"
    [[ -d "$CONFIG_SRC/skills" ]] && cp -r "$CONFIG_SRC/skills" "$BUNDLE_DIR/config/" && \
        log_sub "$(find "$BUNDLE_DIR/config/skills" -name "SKILL.md" | wc -l) skills"
    [[ -f "$CONFIG_SRC/AGENTS.md.template" ]] && cp "$CONFIG_SRC/AGENTS.md.template" "$BUNDLE_DIR/config/"
    [[ -f "$CONFIG_SRC/opencode.json" ]] && cp "$CONFIG_SRC/opencode.json" "$BUNDLE_DIR/opencode.json.example"
else
    log_warn "opencode-config not found, creating basic config"
    cat > "$BUNDLE_DIR/opencode.json.example" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "provider": {
    "local": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local LLM",
      "options": {
        "baseURL": "http://localhost:8080/v1",
        "apiKey": "not-needed"
      },
      "models": {
        "default": { "name": "Default Model" }
      }
    }
  },
  "model": "local/default"
}
EOF
fi

log "Adding installer and docs"
cp "$SCRIPT_DIR/install.sh" "$BUNDLE_DIR/"
chmod +x "$BUNDLE_DIR/install.sh"
cp "$SCRIPT_DIR/BUNDLE_README.md" "$BUNDLE_DIR/README.md"
cp "$SCRIPT_DIR/../WORKFLOW.md" "$BUNDLE_DIR/"

log "Creating archive"
tar -czf "$OUTPUT" -C "$BUNDLE_DIR" .
rm -rf "$BUNDLE_DIR"

size=$(du -h "$OUTPUT" | cut -f1)
echo -e "\n${GREEN}${BOLD}Bundle created: $OUTPUT ($size)${NC}\n"
log "To install: tar -xzf $OUTPUT && ./install.sh"
echo ""
