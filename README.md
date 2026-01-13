# OpenCode Engineering Process

A structured software engineering workflow for [OpenCode](https://opencode.ai) that transforms user stories into working, deployed software through 8 well-defined phases.

## Philosophy

**Assumptions are the enemy.** At every phase, surface implicit beliefs and verify them against reality. Engineers who skip verification and proceed on pattern-matching from past experience tend to struggle.

## Installation

### Option 1: Copy to your project

Copy the `.opencode/` directory and `instructions/` directory to your project root:

```bash
cp -r opencode-engineering-process/.opencode your-project/
cp -r opencode-engineering-process/instructions your-project/
cp opencode-engineering-process/opencode.json your-project/
```

### Option 2: Symlink for development

```bash
ln -s /path/to/opencode-engineering-process/.opencode ~/.config/opencode/
```

## Usage

### Starting a Workflow

```
/story Add user authentication
/story https://github.com/org/repo/issues/123
/story #456
```

### Checking Status

```
/phase          # Show current phase and status
/checkpoint     # Validate current phase completion
```

### Navigating Phases

```
/phase research    # Jump to research phase
/phase implement   # Skip to implementation (with warning)
```

## The 8-Phase Workflow

| Phase | Agent | Purpose |
|-------|-------|---------|
| 1. Understand | - | Comprehend requirements, identify gaps |
| 2. Research | `@explorer` | Explore codebase, verify assumptions |
| 3. Scope | - | Define boundaries, minimal implementation |
| 4. Design | `@architect` | Architecture decisions, document approach |
| 5. Decompose | `@architect` | Break into implementable tasks |
| 6. Implement | `@implementer` | Write code and tests |
| 7. Validate | `@reviewer` | Review, test, verify criteria |
| 8. Deploy | `@implementer` | Release and monitor |

## Specialized Agents

### `@explorer`
- **Purpose**: Research and analyze codebases
- **Access**: Read-only (no write, edit, or bash)
- **Use when**: Gathering context, verifying assumptions

### `@architect`
- **Purpose**: Design solutions, document decisions
- **Access**: Read and write (no edit or bash)
- **Use when**: Planning architecture, creating design docs

### `@implementer`
- **Purpose**: Write and modify code
- **Access**: Full access (read, write, edit, bash)
- **Use when**: Implementing features, writing tests

### `@reviewer`
- **Purpose**: Review code for quality and security
- **Access**: Read and limited bash (no write or edit)
- **Use when**: Validating implementation, code review

## Workflow State

Each story creates a directory with all artifacts:

```
docs/stories/<story-slug>/
├── workflow-state.json    # Progress tracking
├── research-notes.md      # Phase 2 output
├── design.md              # Phase 4 output
└── tasks.md               # Phase 5 output
```

## Commands

| Command | Description |
|---------|-------------|
| `/story <input>` | Start a new engineering workflow |
| `/phase [name]` | View current phase or jump to another |
| `/checkpoint` | Validate current phase completion |

## Project Structure

```
opencode-engineering-process/
├── opencode.json              # Main configuration
├── .opencode/
│   ├── agent/                 # Specialized agents
│   │   ├── explorer.md
│   │   ├── architect.md
│   │   ├── implementer.md
│   │   └── reviewer.md
│   └── command/               # Custom commands
│       ├── story.md
│       ├── phase.md
│       └── checkpoint.md
├── instructions/
│   ├── ENGINEERING_PROCESS.md # Main orchestrator instructions
│   ├── phases/                # Phase-specific instructions
│   │   ├── 1-understand.md
│   │   ├── 2-research.md
│   │   ├── 3-scope.md
│   │   ├── 4-design.md
│   │   ├── 5-decompose.md
│   │   ├── 6-implement.md
│   │   ├── 7-validate.md
│   │   └── 8-deploy.md
│   ├── checklists/            # Validation checklists
│   │   ├── research-checklist.md
│   │   ├── design-checklist.md
│   │   └── completion-checklist.md
│   └── templates/             # Document templates
│       ├── design-doc.md
│       ├── task-breakdown.md
│       └── pr-description.md
└── scripts/
    └── phase-gate.sh          # CLI validation script
```

## Comparison: Claude Code vs OpenCode

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| Config | `.claude-plugin/plugin.json` | `opencode.json` |
| Agents | `agents/*.md` | `.opencode/agent/*.md` |
| Commands | `commands/*.md` | `.opencode/command/*.md` |
| Skills | `skills/*/SKILL.md` | `instructions/*.md` |
| Hooks | `hooks/hooks.json` | Agent permissions |
| Agent delegation | `Delegate to: agent` | `@agent` mentions |

## Requirements

- OpenCode CLI
- `jq` (for phase-gate.sh script)
- Optional: `gh` CLI for GitHub integration

## License

MIT
