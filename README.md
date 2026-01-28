# OpenCode Offline Installer

Fully offline installer for [OpenCode](https://opencode.ai) on Linux x64.

## Quick Start

**Build** (requires internet):
```bash
cd offline && ./pack.sh
```

**Install** (offline):
```bash
tar -xzf opencode-offline.tar.gz && ./install.sh
```

**Configure** your LLM endpoint:
```bash
nano ~/.config/opencode/opencode.json
```

**Run**:
```bash
source ~/.bashrc && opencode
```

## Project Structure

```
├── offline/
│   ├── pack.sh          # Creates the bundle
│   └── install.sh       # Installs on target machine
├── opencode-config/
│   ├── opencode.json    # Main configuration
│   ├── agents/          # 11 agent definitions
│   └── skills/          # 11 skill definitions
└── WORKFLOW.md          # Developer workflow guide
```

## Documentation

- [WORKFLOW.md](WORKFLOW.md) - How to use OpenCode agents
- [opencode-config/README.md](opencode-config/README.md) - Configuration details
