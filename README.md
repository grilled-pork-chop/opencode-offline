# OpenCode Offline

Offline installation toolkit for [OpenCode](https://opencode.ai) on Linux x64 with any OpenAI-compatible local LLM provider.

## Overview

OpenCode is a terminal-based AI coding assistant. By default it requires internet access to download models metadata, npm dependencies, and the binary itself. This project packages everything needed for fully air-gapped deployment.

**What's included:**

- OpenCode binary (Linux x64)
- Node.js runtime (v22.16.0)
- `@ai-sdk/openai-compatible` provider
- Models API cache (prevents startup freeze)
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

This downloads all components and creates `opencode-offline.tar.gz`.

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

| Location                           | Purpose              |
| ---------------------------------- | -------------------- |
| `~/.opencode/bin/opencode`         | OpenCode binary      |
| `~/.opencode/bin/opencode-offline` | Management CLI       |
| `~/.opencode/node/`                | Node.js runtime      |
| `~/.opencode/cache/`               | npm deps + API cache |
| `~/.opencode/env.sh`               | Environment setup    |
| `~/.config/opencode/opencode.json` | Main configuration   |
