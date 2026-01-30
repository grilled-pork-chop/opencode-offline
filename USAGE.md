# OpenCode Offline Bundle

## Install

```bash
./install.sh
source ~/.opencode/env.sh
```

The installer will prompt for:
- **Provider URL**: Your LLM endpoint (e.g., `http://localhost:8000/v1`)
- **Model name**: The model to use (e.g., `deepseek-v32`)

## Installed Files

| Location                           | Purpose            |
| ---------------------------------- | ------------------ |
| `~/.opencode/bin/opencode`         | OpenCode binary    |
| `~/.opencode/node/`                | Node.js runtime    |
| `~/.opencode/env.sh`               | Environment setup  |
| `~/.config/opencode/opencode.json` | Main configuration |
| `~/.opencode/cache/api.json`       | Models API cache   |

## Configuration

### Change Provider

Edit `~/.config/opencode/opencode.json`:

```json
{
  "provider": {
    "local": {
      "options": {
        "baseURL": "http://localhost:8000/v1"
      }
    }
  }
}
```

Common endpoints:
- vLLM: `http://localhost:8000/v1`
- Ollama: `http://localhost:11434/v1`
- LM Studio: `http://localhost:1234/v1`

### Change Model

Update the config file with your model name:
- `~/.config/opencode/opencode.json` → `"model": "local/your-model"`

## Usage

```bash
cd your-project
opencode
```

Just describe what you want:

```
Add a login endpoint
```

## Agents

OpenCode includes two **primary agents** and two **subagents**.

### Primary Agents

Switch between primary agents using the `Tab` key.

| Agent     | Purpose                                     | Tools                         |
| --------- | ------------------------------------------- | ----------------------------- |
| **Build** | Default agent for development work          | All tools enabled             |
| **Plan**  | Analysis and planning without modifications | Read-only (edits require ask) |

#### Build Agent

The default agent with full access to file operations and system commands. Use this for:
- Writing and editing code
- Running commands
- Making changes to your codebase

#### Plan Agent

A restricted agent for analysis and planning. Use this when you want the LLM to:
- Analyze code and architecture
- Suggest changes without modifying files
- Create implementation plans before coding

**Tip:** Start complex features in Plan mode to outline your approach, then switch to Build mode for implementation.

### Subagents

Subagents are invoked automatically by primary agents, or manually using `@agent_name`.

| Agent       | Purpose                       | Tools                     |
| ----------- | ----------------------------- | ------------------------- |
| **General** | Research and multi-step tasks | Full access (except todo) |
| **Explore** | Fast codebase exploration     | Read-only                 |

#### General Agent

A general-purpose agent for researching complex questions and executing multi-step tasks. Can modify files when needed.

```
@general investigate why the auth tests are failing
```

#### Explore Agent

A fast, read-only agent for exploring codebases. Cannot modify files. Use this to:
- Find files by patterns
- Search code for keywords
- Answer questions about the codebase structure

```
@explore find all API endpoints in this project
```

### Navigation

- `Tab` — Switch between primary agents (Build/Plan)
- `Leader+Right` — Navigate to child session
- `Leader+Left` — Navigate to parent session

## Troubleshooting

### Startup freeze

Verify the environment variable is set:

```bash
echo $OPENCODE_MODELS_URL
# Should show: file:///home/user/.opencode/cache
```

## More Information

- [OpenCode documentation](https://opencode.ai)
- [Agents documentation](https://opencode.ai/docs/agents/)
