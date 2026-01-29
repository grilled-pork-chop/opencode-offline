# OpenCode Offline Installer with oh-my-opencode

Complete offline installation package for OpenCode with the oh-my-opencode plugin, configured for local Ollama models.

## What's Included

- **OpenCode** binary (Linux x64)
- **Node.js** v22.16.0
- **oh-my-opencode** plugin with all agents
- **@ai-sdk/openai-compatible** for Ollama provider
- **Configuration files** pre-configured for offline use
- **models.dev API cache** to prevent startup freeze

## Quick Start

### On a machine with internet (packaging):

```bash
# 1. Clone/download this directory
# 2. Run the packager
./pack.sh

# Output: opencode-offline.tar.gz
```

### On the target offline machine:

```bash
# 1. Copy and extract
tar -xzf opencode-offline.tar.gz
cd opencode-offline

# 2. Install
./install.sh

# 3. Activate
source ~/.opencode/env.sh

# 4. Run
opencode
```

## Prerequisites on Target Machine

### Ollama with Models

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull recommended models
ollama pull qwen3-coder:30b    # Primary (18GB VRAM)
ollama pull qwen3:30b          # Advisory agents (18GB VRAM)

# CRITICAL: Increase context window!
ollama run qwen3-coder:30b
>>> /set parameter num_ctx 32768
>>> /save qwen3-coder:30b
>>> /bye

ollama run qwen3:30b
>>> /set parameter num_ctx 32768
>>> /save qwen3:30b
>>> /bye
```

### Alternative: Set context globally

```bash
# In systemd service or shell
export OLLAMA_CONTEXT_LENGTH=32000
```

## Configuration Files

### `~/.config/opencode/opencode.json`

Main OpenCode configuration:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (Local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3-coder:30b": { "name": "Qwen3 Coder 30B", "tools": true },
        "qwen3:30b": { "name": "Qwen3 30B", "tools": true }
      }
    }
  },
  "model": "ollama/qwen3-coder:30b",
  "plugin": ["oh-my-opencode"]
}
```

### `~/.config/opencode/oh-my-opencode.json`

oh-my-opencode configuration with agent model overrides:

```json
{
  "agents": {
    "sisyphus": { "model": "ollama/qwen3-coder:30b" },
    "prometheus": { "model": "ollama/qwen3-coder:30b" },
    "atlas": { "model": "ollama/qwen3-coder:30b" },
    "oracle": { "model": "ollama/qwen3:30b" },
    "explore": { "model": "ollama/qwen3:30b" },
    "librarian": { "model": "ollama/qwen3:30b" },
    "metis": { "model": "ollama/qwen3:30b" },
    "momus": { "model": "ollama/qwen3:30b" }
  },
  "disabled_agents": ["multimodal-looker"],
  "mcp": {
    "websearch_exa": { "enabled": false },
    "context7": { "enabled": false },
    "grep_app": { "enabled": false }
  }
}
```

## oh-my-opencode Agents

All agents from oh-my-opencode work offline with local models:

| Agent | Model | Purpose |
|-------|-------|---------|
| **Sisyphus** | qwen3-coder:30b | Primary orchestrator, TODO-driven workflow |
| **Prometheus** | qwen3-coder:30b | Strategic planner with interview mode |
| **Atlas** | qwen3-coder:30b | Plan executor, delegates to workers |
| **Oracle** | qwen3:30b | Architecture/debugging consultation |
| **Explore** | qwen3:30b | Fast codebase grep |
| **Librarian** | qwen3:30b | Documentation research (local only) |
| **Metis** | qwen3:30b | Plan gap analysis |
| **Momus** | qwen3:30b | Ruthless plan critic |

### Disabled Agents (require cloud/vision):
- **multimodal-looker** - Requires Gemini/GPT-4V for vision

## Usage

### Basic Usage

```bash
# Start OpenCode
opencode

# Use ultrawork mode for automatic execution
# Just include "ultrawork" or "ulw" in your prompt
```

### Invoking Agents

```bash
@explore find all authentication files
@oracle review this architecture
@prometheus plan a new feature
@librarian how does the payment flow work?
```

### Workflow: Simple Task

```
You: "ulw add a login endpoint"
     ↓
Sisyphus: Creates TODO, explores code, implements, verifies
```

### Workflow: Complex Feature

```
You: [Tab to switch to Prometheus]
     "Build user authentication"
     ↓
Prometheus: Interviews you, creates work plan
     ↓
You: "/start-work auth-plan"
     ↓
Atlas: Executes plan, delegates to workers
```

## What Works Offline

| Feature | Status |
|---------|--------|
| All agents (Sisyphus, Oracle, etc.) | ✅ Works |
| TODO continuation hook | ✅ Works |
| Comment checker hook | ✅ Works |
| LSP/AST tools | ✅ Works |
| delegate_task orchestration | ✅ Works |
| git-master skill | ✅ Works |
| Background agents | ✅ Works |

## What's Disabled (Requires Internet)

| Feature | Why Disabled |
|---------|--------------|
| websearch_exa MCP | Needs Exa API |
| context7 MCP | Fetches online docs |
| grep_app MCP | GitHub code search |
| multimodal-looker | Needs vision model |

## Troubleshooting

### Tools not working

Increase Ollama context window:
```bash
ollama run qwen3-coder:30b
>>> /set parameter num_ctx 32768
>>> /save qwen3-coder:30b
```

### OpenCode freezes on startup

Check that `OPENCODE_MODELS_URL` is set:
```bash
echo $OPENCODE_MODELS_URL
# Should output: file:///home/user/.cache/opencode/api.json
```

### Plugin not loading

Check that node_modules exists:
```bash
ls ~/.config/opencode/node_modules/oh-my-opencode
```

### Model not found

Ensure model is pulled and Ollama is running:
```bash
ollama list
ollama serve  # If not running
```

## Model Alternatives

For lower VRAM systems:

| Model | VRAM | Set in oh-my-opencode.json |
|-------|------|----------------------------|
| qwen3-coder:30b | ~18GB | Primary agents |
| qwen3:30b | ~18GB | Advisory agents |
| devstral-small-2:24b | ~15GB | Alternative |
| deepseek-coder-v2:16b | ~10GB | Low VRAM option |
| qwen3-coder:8b | ~5GB | Minimal setup |

## Directory Structure

```
~/.opencode/
├── bin/opencode           # OpenCode binary
├── node/                  # Node.js installation
└── env.sh                 # Environment setup

~/.config/opencode/
├── opencode.json          # Main config
├── oh-my-opencode.json    # Plugin config
├── node_modules/          # Plugin installation
│   └── oh-my-opencode/
└── package.json

~/.cache/opencode/
├── api.json               # Models API cache
├── node_modules/          # Provider dependencies
│   └── @ai-sdk/
└── package.json
```

## Credits

- [OpenCode](https://github.com/sst/opencode) by SST
- [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) by @code-yeongyu
- [Ollama](https://ollama.ai) for local model hosting
