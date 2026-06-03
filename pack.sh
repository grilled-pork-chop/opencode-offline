#!/usr/bin/env bash
#
# OpenCode Offline Packager
# Downloads OpenCode and its version-matched plugin for offline installation (Linux x64 only)
#
set -euo pipefail

# ─── Versions (single source of truth) ───────────────────────────────────────
# Bump OPENCODE_VERSION to upgrade. The @opencode-ai/plugin version MUST match the
# binary version exactly — opencode installs it at startup, which fails offline unless
# the matching, pre-built node_modules is shipped in the bundle.
OPENCODE_VERSION="1.15.13"
OPENCODE_ASSET="opencode-linux-x64.tar.gz"

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
OPENCODE_URL="https://github.com/sst/opencode/releases/download/v${OPENCODE_VERSION}/${OPENCODE_ASSET}"

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
    echo "  OpenCode version: ${OPENCODE_VERSION}"
    echo ""

    for cmd in curl tar npm; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    cleanup

    log_step "Creating directory structure..."
    mkdir -p "$BUNDLE_DIR"/{bin,deps,config}

    # =========================================================================
    # 1. Download OpenCode binary (pinned to OPENCODE_VERSION)
    # =========================================================================
    log_step "Downloading OpenCode binary (v${OPENCODE_VERSION})..."
    local tmp_tar
    tmp_tar=$(mktemp)
    download_file "$OPENCODE_URL" "$tmp_tar"
    tar -xzf "$tmp_tar" -C "$BUNDLE_DIR/bin"
    rm "$tmp_tar"
    chmod +x "$BUNDLE_DIR/bin/opencode"
    log_info "OpenCode binary ready"

    # =========================================================================
    # 2. Build the version-matched plugin dependency set
    # =========================================================================
    # opencode runs an npm install at startup against a package.json in both its install
    # root (~/.opencode) and the config dir (~/.config/opencode), pinned to
    # @opencode-ai/plugin@<binary version>. We pre-build the resulting node_modules +
    # package-lock.json here so that install is a no-op offline. The same set is reused
    # for both target directories at install time.
    log_step "Building plugin dependency set (@opencode-ai/plugin@${OPENCODE_VERSION})..."
    mkdir -p "$BUNDLE_DIR/deps/plugin"
    pushd "$BUNDLE_DIR/deps/plugin" > /dev/null

    cat > package.json << EOF
{
  "dependencies": {
    "@opencode-ai/plugin": "${OPENCODE_VERSION}"
  }
}
EOF

    # Match what opencode writes into these directories.
    cat > .gitignore << 'EOF'
node_modules
package.json
package-lock.json
bun.lock
.gitignore
EOF

    # Match what opencode generates (it creates node_modules/.bin); --ignore-scripts is
    # safe because the native deps ship prebuilt binaries via optionalDependencies.
    npm install --ignore-scripts --no-audit --no-fund 2>&1 \
        | grep -E '(added|npm warn)' || true
    popd > /dev/null

    if [[ ! -d "$BUNDLE_DIR/deps/plugin/node_modules/@opencode-ai/plugin" ]]; then
        log_error "Plugin install failed — @opencode-ai/plugin@${OPENCODE_VERSION} not found"
        exit 1
    fi
    log_info "Plugin dependency set ready"

    # =========================================================================
    # 3. Copy configuration template
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
    # 4. Copy CLI and documentation
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
    # 5. Create archive
    # =========================================================================
    log_step "Creating archive..."
    tar -czf "$OUTPUT_ARCHIVE" -C "$BUNDLE_DIR" .

    rm -rf "$BUNDLE_DIR"

    local size
    size=$(du -h "$OUTPUT_ARCHIVE" | cut -f1)

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      BUILD COMPLETE                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Created: $OUTPUT_ARCHIVE ($size)"
    echo ""
    echo "Contents:"
    echo "  • OpenCode binary v${OPENCODE_VERSION} (Linux x64)"
    echo "  • @opencode-ai/plugin@${OPENCODE_VERSION} (version-matched, pre-built)"
    echo "  • Configuration template"
    echo ""
    echo "To install on target machine:"
    echo "  1. Copy $OUTPUT_ARCHIVE to target"
    echo "  2. tar -xzf $OUTPUT_ARCHIVE"
    echo "  3. ./opencode-offline install"
    echo ""
}

main "$@"
