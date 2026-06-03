# OpenCode Offline Bundle

## Install

```bash
./opencode-offline install
source ~/.opencode/env.sh
```

The installer will prompt for:
- **Provider URL**: Your LLM endpoint (e.g., `http://localhost:8000/v1`)
- **Model name**: The model to use (e.g., `GLM-5.1-FP8`)

## Management

After installation, the `opencode-offline` CLI is available on PATH:

```bash
opencode-offline config       # Change provider URL or model
opencode-offline status       # Show versions and configuration
opencode-offline uninstall    # Remove everything
```

## Installed Files

| Location                                                           | Purpose               |
| ------------------------------------------------------------------ | --------------------- |
| `~/.opencode/bin/opencode`                                         | OpenCode binary       |
| `~/.opencode/bin/opencode-offline`                                 | Management CLI        |
| `~/.opencode/{node_modules,package.json,package-lock.json}`        | Plugin (install root) |
| `~/.opencode/env.sh`                                               | Environment setup     |
| `~/.config/opencode/opencode.json`                                 | Main configuration    |
| `~/.config/opencode/{node_modules,package.json,package-lock.json}` | Plugin (config dir)   |

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

### Wrong provider or model

```bash
opencode-offline config
```

### Permission denied

```bash
chmod +x ~/.opencode/bin/opencode ~/.opencode/bin/opencode-offline
```

## More Information

- [OpenCode documentation](https://opencode.ai)
- [Agents documentation](https://opencode.ai/docs/agents/)
