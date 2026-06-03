# OpenCode Offline

Offline installation toolkit for [OpenCode](https://opencode.ai) on Linux x64 with any OpenAI-compatible local LLM provider.

## Overview

OpenCode is a terminal-based AI coding assistant. On first run it installs `@opencode-ai/plugin` (a package whose version is locked to the binary) from npm — which fails on an air-gapped machine. This project packages the binary together with the matching, pre-built plugin so nothing needs to be fetched at runtime.

**What's included:**

- OpenCode binary (Linux x64), pinned to a specific version
- `@opencode-ai/plugin`, **pre-built and version-matched to the binary**
- Configuration template with placeholder substitution
- `opencode-offline` CLI for install, config, status, and uninstall

The OpenAI-compatible provider SDK is bundled inside the OpenCode binary, and Node.js is not required (the binary is self-contained), so neither is packaged separately.

### Version coupling

`@opencode-ai/plugin` **must** match the OpenCode binary version exactly. Both are driven
by a single `OPENCODE_VERSION` variable at the top of `pack.sh` — bump it and re-run
`./pack.sh` to build a bundle for a new version.

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

This downloads the pinned binary, pre-builds the matching plugin, and creates
`opencode-offline.tar.gz`. To target a different version, edit `OPENCODE_VERSION` at the
top of `pack.sh` first.

**Requirements:** `curl`, `tar`, `npm`

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

| Location                                | Purpose                          |
| --------------------------------------- | -------------------------------- |
| `~/.opencode/bin/opencode`              | OpenCode binary                  |
| `~/.opencode/bin/opencode-offline`      | Management CLI                   |
| `~/.opencode/{node_modules,package.json,package-lock.json}` | Plugin (install root) |
| `~/.opencode/env.sh`                    | Environment setup                |
| `~/.config/opencode/opencode.json`      | Main configuration               |
| `~/.config/opencode/{node_modules,package.json,package-lock.json}` | Plugin (config dir) |
