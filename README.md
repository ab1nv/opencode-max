<p align="center">
  <img src="https://img.shields.io/badge/OpenCode-MAX-fe8019?style=for-the-badge&logoColor=white" alt="OpenCode MAX" />
  <img src="https://img.shields.io/github/v/tag/ab1nv/opencode-max?style=for-the-badge&color=fabd2f&label=version" alt="Version" />
  <img src="https://img.shields.io/badge/Theme-Gruvbox-fbf1c7?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgZmlsbD0iI2ZlODAxOSIvPjwvc3ZnPg==&logoColor=282828" alt="Gruvbox Theme" />
  <img src="https://img.shields.io/badge/Agents-12-b8bb26?style=for-the-badge" alt="12 Agents" />
  <img src="https://img.shields.io/badge/Skills-6-83a598?style=for-the-badge" alt="6 Skills" />
  <img src="https://img.shields.io/badge/Commands-14-b8bb26?style=for-the-badge" alt="14 Commands" />
  <img src="https://img.shields.io/badge/Tools-2-d3869b?style=for-the-badge" alt="2 Tools" />
</p>

<h1 align="center">
  <img src="https://i.ibb.co/fYqjLsjz/opencode-max-logo.png" alt="OpenCode MAX" />
</h1>

<p align="center">
  <strong>Turn vanilla OpenCode into a god-tier AI coding assistant.</strong><br/>
  A drop-in configuration that gives you specialized agents, battle-tested skills, powerful custom commands, and a gorgeous Gruvbox theme — all designed to outperform Claude Code, Cursor, and every other AI coding tool.
</p>

<p align="center">
  <strong>Tired of constantly discovering new AI coding tricks, prompt patterns, and agent enhancements?</strong><br/>
  Every week there's a new "best way" to use Claude Code, a new skill pattern, a new agent workflow.
  OpenCode MAX does the research so you don't have to — we track every meaningful advancement in AI-assisted development
  and bake it into this configuration, so you can stay focused on <em>writing great code</em>
  instead of endlessly tuning your tools.
</p>

<p align="center">
  <a href="#quick-install">Installation</a> •
  <a href="#whats-included">What's Included</a> •
  <a href="#agents">Agents</a> •
  <a href="#commands">Commands</a> •
  <a href="#skills">Skills</a> •
  <a href="#customization">Customize</a>
</p>

---

## Why OpenCode MAX?

Most people use OpenCode with default settings. That's like driving a Ferrari in first gear.

OpenCode MAX gives you:

| Feature | Vanilla OpenCode | OpenCode MAX |
|---------|-----------------|--------------|
| Agents | 2 (Build + Plan) | **12 specialized agents** |
| Commands | 5 built-in | **14+ custom commands** |
| Skills | None | **6 reusable workflows** |
| Theme | Default | **Custom Gruvbox** with full syntax highlighting |
| Permissions | Wide open | **Granular security** with safe defaults |
| Prompts | Generic | **Expert-crafted** system prompts per agent |
| Debugging | Manual | **Hypothesis-driven** debug loop |
| Code Review | Manual | **One-command** `/review` with severity ratings |
| Git | Manual | **Auto-generated** conventional commits |
| Security | None | **Built-in** security audit command |

---

## Quick Install

### Option 1: One-Line Install (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/ab1nv/opencode-max/master/install.sh | bash
```

### Option 2: Clone & Install

```bash
git clone https://github.com/ab1nv/opencode-max.git
cd opencode-max
./install.sh
```

The installer will ask you:
1. **Current project** — Copies configs to your working directory
2. **Global** — Installs to `~/.config/opencode/` (applies everywhere)
3. **Both** — Global + current project
4. **Update** — Safe update mode (does not overwrite modified files)

### Option 2: Manual Install

```bash
# Clone the repo
git clone https://github.com/ab1nv/opencode-max.git

# Copy to your project
cp opencode-max/opencode.json ./
cp opencode-max/tui.json ./
cp opencode-max/AGENTS.md ./
cp -r opencode-max/.opencode/ ./.opencode/
cp -r opencode-max/prompts/ ./prompts/

# Or copy globally
cp opencode-max/opencode.json ~/.config/opencode/
cp opencode-max/tui.json ~/.config/opencode/
cp opencode-max/AGENTS.md ~/.config/opencode/
cp -r opencode-max/.opencode/themes/ ~/.config/opencode/themes/
cp -r opencode-max/.opencode/agents/ ~/.config/opencode/agents/
cp -r opencode-max/.opencode/commands/ ~/.config/opencode/commands/
cp -r opencode-max/.opencode/skills/ ~/.config/opencode/skills/
```

### Option 3: Cherry-Pick What You Need

Only want the theme? Copy `.opencode/themes/gruvbox-max.json`.
Only want agents? Copy `.opencode/agents/` and `opencode.json`.
Mix and match whatever works for you.

---

## What's Included

```
opencode-max/
├── opencode.json               # Main config — agents, permissions, commands, MCP
├── tui.json                    # TUI theme & keybindings
├── AGENTS.md                   # Global rules & coding standards
├── install.sh                  # Interactive installer
│
├── prompts/                    # Agent system prompts
│   ├── build.md                # Build agent prompt
│   ├── plan.md                 # Plan agent prompt
│   ├── architect.md            # Architect agent prompt
│   └── debugger.md             # Debugger agent prompt
│
└── .opencode/
    ├── themes/
    │   └── gruvbox-max.json    # Custom Gruvbox theme
    │
    ├── agents/                 # Markdown-based subagents
    │   ├── grill-me.md         # Design decision challenger
    │   ├── perf-profiler.md    # Performance analyzer
    │   └── changelog.md        # Changelog generator
    │
    ├── commands/               # Custom slash commands
    │   ├── pre-commit.md       # Pre-commit review
    │   ├── overview.md         # Project overview
    │   ├── diff-summary.md     # Change summary
    │   └── explain.md          # Code explainer
    │
    ├── tools/                  # Custom callable tools
    │   ├── handoff.ts          # Save/load session handoff notes
    │   └── run-checks.ts       # Run ordered verification commands
    │
    └── skills/                 # Reusable workflow skills
        ├── plan-first/         # Plan-before-code workflow
        ├── tdd/                # Test-driven development
        ├── code-review/        # Review checklist
        ├── git-commit/         # Conventional commits
        ├── debug-loop/         # Hypothesis-driven debugging
        └── to-prd/             # Idea → PRD converter
```

---

## Agents

OpenCode MAX ships with **12 specialized agents**: 3 primary agents you can switch between with `Tab`, and 9 subagents invokable with `@`.

### Primary Agents (switch with `Tab`)

| Agent | Color | Purpose |
|-------|-------|---------|
| **Build** | Orange | Full-power implementation: all tools enabled |
| **Plan** | Blue | Read-only analysis and planning: never modifies files |
| **Architect** | Purple | System design and architecture decisions |

### Subagents (invoke with `@agent-name`)

| Agent | Invoke | Purpose |
|-------|--------|---------|
| **Code Reviewer** | `@code-reviewer` | Deep review with security, correctness, and performance checks |
| **Debugger** | `@debugger` | Systematic hypothesis-driven bug investigation |
| **Docs Writer** | `@docs-writer` | Technical documentation and README generation |
| **Security Auditor** | `@security-auditor` | OWASP-based security vulnerability scanning |
| **Refactor** | `@refactor` | Code quality improvement without behavior change |
| **Explorer** | `@explorer` | Fast read-only codebase navigation (10 step limit) |
| **Grill Me** | `@grill-me` | Socratic challenger: pressure-tests your design decisions |
| **Perf Profiler** | `@perf-profiler` | Finds bottlenecks, N+1 queries, and complexity issues |
| **Changelog** | `@changelog` | Generates changelogs from git history |

### How Agents Work

```
┌─────────────────────────────────────────────┐
│              Primary Agents                 │
│  ┌─────────┐  ┌──────┐  ┌───────────┐       │
│  │  Build  │──│ Plan │──│ Architect │  Tab  │
│  └────┬────┘  └──────┘  └───────────┘       │
│       │                                     │
│       ▼ Delegates to subagents              │
│  ┌──────────────────────────────────┐       │
│  │ @code-reviewer  @debugger        │       │
│  │ @docs-writer    @security        │       │
│  │ @refactor       @explorer        │       │
│  │ @grill-me       @perf-profiler   │       │
│  │ @changelog                       │       │
│  └──────────────────────────────────┘       │
└─────────────────────────────────────────────┘
```

---

## Commands

Type `/` in OpenCode to see all commands. OpenCode MAX adds **14 custom commands**:

### Development

| Command | Description |
|---------|-------------|
| `/test` | Run tests, analyze failures, suggest fixes |
| `/tdd <feature>` | Test-driven development workflow |
| `/debug <issue>` | Systematic hypothesis-driven debugging |
| `/refactor <target>` | Refactor code while preserving behavior |

### Review & Quality

| Command | Description |
|---------|-------------|
| `/review` | Full code review on staged changes |
| `/pre-commit` | Pre-commit quality check with go/no-go verdict |
| `/security` | OWASP-based security audit |
| `/perf <target>` | Performance analysis and optimization suggestions |

### Planning & Documentation

| Command | Description |
|---------|-------------|
| `/plan <task>` | Create a detailed implementation plan |
| `/doc <target>` | Generate documentation for a file or module |
| `/explain <target>` | Plain-English code explanation |
| `/overview` | Quick project overview and tech stack scan |

### Git

| Command | Description |
|---------|-------------|
| `/commit` | Generate conventional commit message from staged changes |
| `/diff-summary` | Summarize all uncommitted changes |

### Examples

```bash
# Review your staged changes before committing
/review

# Plan a new feature
/plan Add user authentication with JWT

# Debug a specific issue
/debug Users can't login after password reset

# Generate a commit message
/commit

# Explain unfamiliar code
/explain src/auth/middleware.ts

# Run TDD for a new feature
/tdd Add email validation to signup form
```

---

## Skills

Skills are reusable workflow instructions that agents load on-demand. They teach the AI HOW to approach specific types of tasks.

| Skill | Trigger | What It Does |
|-------|---------|--------------|
| **plan-first** | Complex tasks (3+ files) | Enforces requirements → discovery → plan → approval → execution |
| **tdd** | `/tdd` or test-related tasks | Red → Green → Refactor cycles |
| **code-review** | `/review` or review tasks | Structured checklist: security, correctness, perf, design |
| **git-commit** | `/commit` | Conventional commit message generation |
| **debug-loop** | `/debug` or bug reports | Hypothesis-driven: gather → hypothesize → test → fix → prevent |
| **to-prd** | New features / ideas | Converts rough ideas into structured PRDs |

---

## Custom Tools

OpenCode MAX includes lightweight custom tools in `.opencode/tools/`:

| Tool | Purpose |
|------|---------|
| `handoff_save` / `handoff_load` | Persist and restore structured handoff notes across sessions |
| `run-checks` | Run tests/lint/typecheck commands in sequence with a compact report |

---

## Gruvbox MAX Theme

A carefully crafted Gruvbox dark theme with:

- **Warm orange** primary accents (`#fe8019`)
- **Tinted diff backgrounds** — green-tinted for additions, red-tinted for removals
- **Full syntax highlighting** — 9 distinct token colors
- **High contrast** — dark background (`#1d2021`) with light text (`#ebdbb2`)
- **Active borders** — orange glow on focused elements

### Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Orange | `#fe8019` |
| Secondary | Blue | `#83a598` |
| Accent | Aqua | `#8ec07c` |
| Success | Green | `#b8bb26` |
| Warning | Yellow | `#fabd2f` |
| Error | Red | `#fb4934` |
| Info | Blue | `#83a598` |
| Background | Dark | `#1d2021` |
| Text | Light | `#ebdbb2` |

---

## Permissions

OpenCode MAX uses a **secure-by-default** permission model:

### Auto-allowed (no prompt)
- Reading files (except `.env`)
- Git read operations (`status`, `diff`, `log`, `branch`, `show`)
- Search tools (`grep`, `rg`, `find`, `ls`, `cat`)
- Test runners (`npm test`, `jest`, `vitest`, `pytest`, `cargo test`)
- Linters and type checkers (`tsc`, `eslint`, `prettier`, `clippy`)
- Build commands (`npm run build`, `cargo build`, `go build`)
- Web fetch and search

### Ask first (prompts for approval)
- Git write operations (`commit`, `push`, `merge`, `rebase`, `checkout`)
- Docker commands
- Make commands
- External directory access
- Doom loop detection (same tool called 3x with same input)

### Blocked (denied)
- Destructive commands (`rm`, `rm -rf`)
- System commands (`sudo`, `chmod`, `chown`)
- Reading `.env` files

### Agent-specific permissions
Each agent has tailored permissions:
- **Build**: Full power, blocks destructive commands
- **Plan**: Read-only — cannot edit files or run most commands
- **Code Reviewer**: Read-only + git diff/log
- **Debugger**: Can edit + run tests, needs approval for other commands

---

## Keybindings

| Action | Shortcut |
|--------|----------|
| Switch agent | `Tab` / `Shift+Tab` |
| Leader key | `Ctrl+X` |
| New session | `<Leader>` + `N` |
| Session list | `<Leader>` + `L` |
| Compact session | `<Leader>` + `C` |
| Model list | `<Leader>` + `M` |
| Agent list | `<Leader>` + `A` |
| Command list | `Ctrl+P` |
| Copy messages | `<Leader>` + `Y` |
| Undo | `<Leader>` + `U` |
| Toggle sidebar | `<Leader>` + `B` |
| Toggle tips | `<Leader>` + `H` |
| Exit | `Ctrl+C` / `Ctrl+D` |

---

## Customization

### Change the model

Edit `opencode.json` and update the `model` field for any agent:

```jsonc
{
  "agent": {
    "build": {
      "model": "openai/gpt-5.1-codex"  // or any provider/model
    }
  }
}
```

### Add your own agent

Create a markdown file in `.opencode/agents/`:

```markdown
---
description: My custom agent
mode: subagent
temperature: 0.3
permission:
  edit: allow
  bash:
    "*": ask
---

You are a custom agent. Do amazing things.
```

### Add a new command

Create a markdown file in `.opencode/commands/`:

```markdown
---
description: My custom command
agent: build
---

Do something cool with: $ARGUMENTS
```

### Add a new skill

Create `.opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does
---

## Instructions for the agent...
```

### Add an MCP server

Edit `opencode.json`:

```jsonc
{
  "mcp": {
    "my-server": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-server"],
      "enabled": true
    }
  }
}
```

### Change the theme

Either use a built-in theme in `tui.json`:
```json
{ "theme": "tokyonight" }
```

Or modify `.opencode/themes/gruvbox-max.json` to your liking.

---

## Pro Tips

### 1. Use the right agent for the job
Don't use Build for planning. Don't use Plan for coding. Hit `Tab` to switch.

### 2. Start with `/plan` for complex tasks
Before touching code, run `/plan <description>`. This creates a structured plan that the Build agent can follow.

### 3. Use `/review` before every commit
One command catches bugs, security issues, and style problems. Much cheaper than production bugs.

### 4. Invoke subagents with `@`
Type `@debugger investigate the login timeout` to delegate to a specialist without leaving your main conversation.

### 5. Use skills for workflow enforcement
The `plan-first` skill ensures agents don't jump into code without a plan. The `tdd` skill enforces Red-Green-Refactor.

### 6. Chain commands for power workflows
```
/plan Add pagination to /api/users
# Review the plan, approve it
# Switch to Build agent (Tab)
# Implement the plan
/test
/review
/commit
```

### 7. Use `/pre-commit` as your quality gate
It gives a clear safe/fix/do-not-commit verdict before you commit.

### 8. Let `@grill-me` challenge your decisions
Before finalizing architecture, invoke `@grill-me` to find blind spots.

---

## Reference Docs

This configuration is inspired by and built upon:

- [OpenCode Documentation](https://opencode.ai/docs) — Official docs
- [Graphify](https://github.com/safishamsi/graphify) — Knowledge graph skill patterns
- [Claude Code Templates](https://github.com/anthropics/claude-code) — Agent configuration patterns
- [Matt Pocock's Skills](https://github.com/mattpocock/skills) — Workflow skill design
- [Oh My Codex (OmX)](https://github.com/hiaux0/oh-my-codex) — Agent orchestration patterns
- [Andrej Karpathy's LLM Skills](https://karpathy.ai/) - Base of entire design

---