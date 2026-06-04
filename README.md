# OpenCode Offline

[![CI](https://github.com/grilled-pork-chop/opencode-offline/actions/workflows/ci.yml/badge.svg)](https://github.com/grilled-pork-chop/opencode-offline/actions/workflows/ci.yml)

Offline installation toolkit for [OpenCode](https://opencode.ai) on Linux x64 with any OpenAI-compatible local LLM provider.

## Overview

OpenCode is a terminal-based AI coding assistant. The binary is self-contained, but on an air-gapped machine it would otherwise reach the network at startup (auto-update checks, model-list and LSP downloads). This project packages the binary with an offline-friendly configuration so nothing is fetched at runtime.

**What's included:**

- OpenCode binary (Linux x64), pinned to a specific version
- Configuration template with placeholder substitution
- `opencode-offline` CLI for install, config, status, and uninstall

## Project Structure

```
opencode-offline/
├── pack.sh                 # Packager — runs on internet machine
├── opencode-offline        # CLI — bundled into archive, used on target
├── templates/
│   └── opencode.json       # Config template with __PROVIDER_URL__ / __MODEL_NAME__
├── USAGE.md                # Bundle documentation (becomes README.md in archive)
└── README.md               # This file (project documentation)
```

## Quick Start

### 1. Build the bundle (internet machine)

```bash
./pack.sh
```

This downloads the pinned binary and creates `opencode-offline.tar.gz`. To target a
different version, edit `OPENCODE_VERSION` at the top of `pack.sh` first.

**Requirements:** `curl`, `tar`

### 2. Transfer

Copy `opencode-offline.tar.gz` to the offline target machine.

### 3. Install (offline target)

```bash
tar -xzf opencode-offline.tar.gz
./opencode-offline install
source ~/.opencode/env.sh
opencode
```

The installer prompts for your LLM provider URL and model name.

## CLI Reference

After installation, `opencode-offline` is available on PATH:

| Command                      | Description                        |
| ---------------------------- | ---------------------------------- |
| `opencode-offline install`   | Install from extracted bundle      |
| `opencode-offline config`    | Change provider URL or model       |
| `opencode-offline status`    | Show installed versions and config |
| `opencode-offline uninstall` | Remove all installed files         |

## Installed Files

| Location                           | Purpose            |
| ---------------------------------- | ------------------ |
| `~/.opencode/bin/opencode`         | OpenCode binary    |
| `~/.opencode/bin/opencode-offline` | Management CLI     |
| `~/.opencode/env.sh`               | Environment setup  |
| `~/.config/opencode/opencode.json` | Main configuration |

## Development

```bash
make lint    # shellcheck the scripts + validate the config JSON
make pack    # build the bundle (same as ./pack.sh)
make clean   # remove build outputs
```

CI (`.github/workflows/ci.yml`) runs the lint on every push and pull request.

## License

MIT — see [LICENSE](LICENSE).
