# OpenCode Offline Installation

Simple offline installation scripts for OpenCode on **Linux x64** systems.

## Quick Start

### On Machine with Internet (Build)

```bash
./pack.sh
```

This creates `opencode-offline.tar.gz` containing:
- OpenCode binary (latest version)
- Node.js runtime
- Required npm dependencies
- **models.json cache** (prevents startup hang)
- Sample config for private LLM

### On Target Machine (Install)

```bash
tar -xzf opencode-offline.tar.gz
./install.sh
```

**Important:** Edit the config with your LLM endpoint:
```bash
nano ~/.config/opencode/opencode.json
```

Then start:
```bash
source ~/.bashrc  # or restart terminal
cd your-project
opencode
```

## Configuration for Private LLM

The installer creates a sample config at `~/.config/opencode/opencode.json`. 
Edit it to point to your private LLM server:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "provider": {
    "my_provider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My Private LLM",
      "options": {
        "baseURL": "http://your-llm-server:8080/v1",
        "apiKey": "your-api-key"
      },
      "models": {
        "your-model-id": {
          "name": "Your Model Name",
          "attachment": false,
          "reasoning": false
        }
      }
    }
  },
  "model": "my_provider/your-model-id"
}
```

### Example: Using with Ollama

```json
{
  "autoupdate": false,
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "ollama"
      },
      "models": {
        "qwen2.5-coder:32b": {
          "name": "Qwen 2.5 Coder 32B"
        }
      }
    }
  },
  "model": "ollama/qwen2.5-coder:32b"
}
```

### Example: Using with vLLM

```json
{
  "autoupdate": false,
  "provider": {
    "vllm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "vLLM Server",
      "options": {
        "baseURL": "http://your-vllm-server:8000/v1",
        "apiKey": "dummy"
      },
      "models": {
        "Qwen/Qwen2.5-Coder-32B-Instruct": {
          "name": "Qwen 2.5 Coder 32B"
        }
      }
    }
  },
  "model": "vllm/Qwen/Qwen2.5-Coder-32B-Instruct"
}
```

## What Gets Installed

| Component       | Location                           |
| --------------- | ---------------------------------- |
| OpenCode binary | `~/.opencode/bin/opencode`         |
| Node.js         | `~/.opencode/node/`                |
| Models cache    | `~/.cache/opencode/models.json`    |
| Dependencies    | `~/.cache/opencode/node_modules/`  |
| Config          | `~/.config/opencode/opencode.json` |

## Why models.json?

OpenCode tries to fetch `https://models.dev/api.json` on every startup. Without network access, this causes the application to hang. The pack script pre-downloads this file so OpenCode can start immediately in offline environments.

## Customization

### Environment Variables

- `OPENCODE_INSTALL_DIR` - Override default install location (`~/.opencode`)

### Modify Node.js Version

Edit `NODE_VERSION` in `pack.sh`:
```bash
NODE_VERSION="v22.16.0"
```

### Add/Remove Dependencies

Edit `DEPS_PACKAGES` array in `pack.sh`:
```bash
DEPS_PACKAGES=(
    "@opencode-ai/plugin@latest"
    "opencode-anthropic-auth@latest"
    "@openauthjs/openauth@latest"
    "@gitlab/opencode-gitlab-auth@latest"
)
```

## Requirements

### Build Machine
- `curl`
- `tar`
- `npm`
- Internet access

### Target Machine
- Linux x64 (glibc)
- `tar` with xz support
- Private LLM server (Ollama, vLLM, etc.)

## Files

```
.
├── pack.sh      # Run on internet-connected machine
├── install.sh   # Included in bundle, run on target
└── README.md
```

## Troubleshooting

### OpenCode hangs on startup
- Verify `~/.cache/opencode/models.json` exists
- Check that `autoupdate: false` is in your config

### "Provider not found" error
- Make sure your provider config is correct in `opencode.json`
- Verify the LLM server is reachable from the target machine

### Node.js not found
- Run `source ~/.bashrc` or restart terminal
- Check PATH includes `~/.opencode/node/bin`