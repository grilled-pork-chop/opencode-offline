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

| Location                                 | Purpose              |
| ---------------------------------------- | -------------------- |
| `~/.opencode/bin/opencode`               | OpenCode binary      |
| `~/.opencode/node/`                      | Node.js runtime      |
| `~/.opencode/env.sh`                     | Environment setup    |
| `~/.config/opencode/opencode.json`       | Main configuration   |
| `~/.config/opencode/oh-my-opencode.json` | Plugin configuration |
| `~/.opencode/cache/api.json`             | Models API cache     |

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

Update both config files with your model name:
- `~/.config/opencode/opencode.json` → `"model": "local/your-model"`
- `~/.config/opencode/oh-my-opencode.json` → agent model overrides

## Usage

```bash
cd your-project
opencode
```

### Quick Tasks

Just describe what you want:

```bash
Add a login endpoint
```

For autonomous execution, include "ultrawork" or "ulw":

```bash
/ulw refactor the auth module
```

### Agents

oh-my-opencode provides specialized agents:

| Agent          | Purpose                                     |
| -------------- | ------------------------------------------- |
| **Sisyphus**   | Default orchestrator, handles complex tasks |
| **Prometheus** | Strategic planner with interview mode       |
| **Atlas**      | Plan executor                               |
| **Oracle**     | Architecture review (read-only)             |
| **Explore**    | Fast codebase search                        |

Invoke directly: `@oracle review this architecture`

### Planning Workflow

For complex features:

```bash
@plan build user authentication
```

Prometheus will interview you, then create a plan in `.sisyphus/plans/`.

Execute the plan:

```bash
/start-work
```

### Commands

| Command              | Description                     |
| -------------------- | ------------------------------- |
| `/start-work`        | Execute a Prometheus plan       |
| `/ralph-loop "task"` | Self-continuing loop until done |
| `/refactor`          | Intelligent refactoring         |

## Troubleshooting

### Context window too small

Increase context for your model. For Ollama:

```bash
ollama run your-model
>>> /set parameter num_ctx 32768
>>> /save your-model
```

### Startup freeze

Verify the environment variable is set:

```bash
echo $OPENCODE_MODELS_URL
# Should show: file:///home/user/.opencode/cache
```

### Plugin not loading

Check node_modules exists:

```bash
ls ~/.config/opencode/node_modules/oh-my-opencode
```

## More Information

- [oh-my-opencode documentation](https://github.com/code-yeongyu/oh-my-opencode)
- [OpenCode documentation](https://opencode.ai)
