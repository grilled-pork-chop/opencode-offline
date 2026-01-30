# OpenCode Offline Installer

Offline installation bundle for [OpenCode](https://opencode.ai) on Linux x64.

## Build (requires internet)

```bash
./pack.sh
```

Creates `opencode-offline.tar.gz`.

## Install (offline)

```bash
tar -xzf opencode-offline.tar.gz
./install.sh
source ~/.opencode/env.sh
```

The installer prompts for your LLM provider URL and model name.

## Run

```bash
cd your-project
opencode
```

See the bundle's README for configuration and usage details.
