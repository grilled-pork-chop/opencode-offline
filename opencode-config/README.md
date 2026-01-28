# OpenCode Offline Configuration Package

Complete agent and skill definitions for Claude Code–like behavior with local LLMs.

## Contents

```
opencode-config/
├── opencode.json              # Main configuration file
├── auth.json                  # Provider authentication (create manually)
├── AGENTS.md.template         # Template for project-specific instructions
├── agents/                    # Agent definitions
│   ├── build-strict.md        # Primary: Strict coding with plan-diff-verify
│   ├── plan.md                # Primary: Read-only analysis and planning
│   ├── review.md              # Subagent: Code review
│   ├── refactor.md            # Subagent: Safe refactoring
│   ├── test.md                # Subagent: Test writing
│   ├── docs.md                # Subagent: Documentation
│   ├── debug.md               # Subagent: Systematic debugging
│   ├── security.md            # Subagent: Security audit
│   ├── git.md                 # Subagent: Git workflow
│   ├── architect.md           # Subagent: System design
│   └── explore.md             # Subagent: Codebase navigation
└── skills/                    # Skill definitions
    ├── diff-editing/SKILL.md       # Core: Minimal surgical edits
    ├── anti-hallucination/SKILL.md # Core: Verify before assuming
    ├── planning/SKILL.md           # Workflow: Implementation planning
    ├── testing/SKILL.md            # Quality: Test writing patterns
    ├── error-handling/SKILL.md     # Quality: Exception patterns
    ├── code-review/SKILL.md        # Quality: Review checklist
    ├── git-workflow/SKILL.md       # Workflow: Git best practices
    ├── python-patterns/SKILL.md    # Language: Python idioms
    ├── typescript-patterns/SKILL.md # Language: TypeScript idioms
    ├── documentation/SKILL.md      # Quality: Doc writing
    └── debugging/SKILL.md          # Workflow: Debug methodology
```

## Installation

### 1. Copy to Global Config

```bash
# Create config directories
mkdir -p ~/.config/opencode/agents
mkdir -p ~/.config/opencode/skills

# Copy configuration
cp opencode.json ~/.config/opencode/
cp -r agents/* ~/.config/opencode/agents/
cp -r skills/* ~/.config/opencode/skills/
```

### 2. Create auth.json

Create `~/.config/opencode/auth.json`:

```json
{
  "local": {
    "api_key": "not-required"
  }
}
```

### 3. Update Model Configuration

Edit `~/.config/opencode/opencode.json`:

1. Change `"your-model-name"` to your actual model name
2. Update `baseURL` to your inference server address
3. Adjust `tools` and `reasoning` based on model capabilities

### 4. Copy AGENTS.md Template to Projects

```bash
cp AGENTS.md.template /path/to/your/project/AGENTS.md
# Then customize for your specific project
```

## Agent Summary

| Agent | Mode | Purpose | Tools |
|-------|------|---------|-------|
| `build-strict` | Primary | Code changes with plan-diff-verify | All (with ask) |
| `plan` | Primary | Read-only analysis | Read only |
| `review` | Subagent | Code review | Read only |
| `refactor` | Subagent | Safe refactoring | Edit + test |
| `test` | Subagent | Write tests | Test files only |
| `docs` | Subagent | Documentation | Doc files only |
| `debug` | Subagent | Bug investigation | All (with ask) |
| `security` | Subagent | Security audit | Read only |
| `git` | Subagent | Git workflow help | Git commands |
| `architect` | Subagent | System design | Read + doc write |
| `explore` | Subagent | Codebase navigation | Read only |

## Skill Summary

| Skill | Category | Purpose |
|-------|----------|---------|
| `diff-editing` | Core | Minimal surgical code changes |
| `anti-hallucination` | Core | Verify APIs/paths before using |
| `planning` | Workflow | Structured implementation plans |
| `testing` | Quality | Test patterns and mocking |
| `error-handling` | Quality | Exception best practices |
| `code-review` | Quality | Systematic review checklist |
| `git-workflow` | Workflow | Commits, branches, PRs |
| `python-patterns` | Language | Python idioms and types |
| `typescript-patterns` | Language | TypeScript patterns |
| `documentation` | Quality | Docstrings, READMEs, API docs |
| `debugging` | Workflow | Scientific debugging method |

## Usage

### Switch Agents

- **Tab**: Cycle between primary agents (build ↔ plan)
- **@agent**: Invoke subagent (e.g., `@review check this function`)

### Load Skills

Skills are loaded automatically when relevant. The agent sees available skills and loads them on demand.

### Recommended Workflow

1. **Start in Plan mode** (Tab to switch)
2. **Analyze and plan** the change
3. **Switch to Build mode** (Tab)
4. **Execute** with "implement the plan"
5. **Review** each edit prompt
6. **Verify** tests pass

## Customization

### Add Project-Specific Agents

Create `.opencode/agents/my-agent.md` in your project:

```markdown
---
description: My custom agent
mode: subagent
temperature: 0.2
---

Custom instructions here.
```

### Add Project-Specific Skills

Create `.opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does
---

Skill instructions here.
```

### Override Global Config Per-Project

Create `opencode.json` in project root to override global settings.

## Troubleshooting

### Agent Not Loading

1. Check file is in correct location
2. Verify frontmatter YAML is valid
3. Check `mode` is set correctly

### Skill Not Appearing

1. Verify `SKILL.md` is uppercase
2. Check `name` and `description` in frontmatter
3. Ensure skill directory name matches `name` field

### Model Connection Issues

1. Verify inference server is running
2. Check `baseURL` in config
3. Test with `curl http://127.0.0.1:8000/v1/models`
