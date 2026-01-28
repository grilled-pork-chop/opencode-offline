# OpenCode Configuration

Agent and skill definitions for local LLM usage.

## Contents

| Folder | Contents |
|--------|----------|
| `agents/` | 11 agent definitions |
| `skills/` | 11 skill definitions |
| `opencode.json` | Main configuration |
| `AGENTS.md.template` | Project template |

## Agents

| Agent | Purpose |
|-------|---------|
| `build-strict` | Primary coding agent |
| `plan` | Read-only analysis |
| `explore` | Codebase navigation |
| `architect` | System design |
| `review` | Code review |
| `test` | Test writing |
| `debug` | Bug investigation |
| `security` | Security audit |
| `refactor` | Safe refactoring |
| `docs` | Documentation |
| `git` | Git workflow |

## Skills

| Skill | Purpose |
|-------|---------|
| `planning` | Implementation planning |
| `testing` | Test patterns |
| `debugging` | Debug methodology |
| `code-review` | Review checklist |
| `git-workflow` | Git best practices |
| `documentation` | Doc writing |
| `diff-editing` | Surgical edits |
| `anti-hallucination` | Verify before assuming |
| `error-handling` | Exception patterns |
| `python-patterns` | Python idioms |
| `typescript-patterns` | TypeScript patterns |

## Manual Installation

```bash
mkdir -p ~/.config/opencode/{agents,skills}
cp opencode.json ~/.config/opencode/
cp -r agents/* ~/.config/opencode/agents/
cp -r skills/* ~/.config/opencode/skills/
```

## Configuration

Edit `~/.config/opencode/opencode.json` to set your LLM endpoint:

```json
"baseURL": "http://localhost:8080/v1"
```

## Usage

- **Tab** - Switch between Build and Plan modes
- **@agent** - Invoke a subagent (e.g., `@review check this function`)
