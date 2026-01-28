# OpenCode Offline Bundle

## Install

```bash
./install.sh
source ~/.bashrc
```

## Configure

Edit `~/.config/opencode/opencode.json`:

```json
"baseURL": "http://localhost:11434/v1"
```

| Server | URL |
|--------|-----|
| Ollama | `http://localhost:11434/v1` |
| vLLM | `http://localhost:8000/v1` |
| LM Studio | `http://localhost:1234/v1` |

## Run

```bash
cd your-project
opencode
/init
```

## Next Steps

See [WORKFLOW.md](WORKFLOW.md) for how to use agents.
