# CLI Agent Management System - Quick Start

Get started with the CLI agent management system for oh-my-tmux.

---

## What is this?

A system to manage multiple CLI tools (aider, cursor-cli, gpt-cli, etc.) from within tmux. Each agent runs in its own isolated session, and you can create dashboards to monitor multiple agents simultaneously.

---

## Quick Setup

The system is already installed as part of this oh-my-tmux configuration. No additional setup required!

---

## Key Features

1. **Agent Sessions**: Dedicated tmux sessions for each CLI tool
2. **Agent Dashboards**: Multi-pane view monitoring multiple agents
3. **Agent Workflows**: Chain agents together for complex tasks
4. **Quick Switch**: Fast navigation between agents

---

## Usage Examples

### Starting an Agent Session

```bash
# Start an agent session
agent-session start aider

# Start with custom arguments
agent-session start gpt-cli --args "--model gpt-4-turbo"

# List all running agent sessions
agent-session list

# Stop an agent session
agent-session stop aider

# Switch to an agent session
agent-session switch aider
```

### Creating a Dashboard

```bash
# Create dashboard with specific agents
agent-dashboard create "my-dashboard" --agents aider,gpt-cli,anthropic-cli

# Create with specific layout
agent-dashboard create "review-dashboard" --layout 2x2 --agents aider,cursor-cli

# List saved dashboards
agent-dashboard list

# Load a saved dashboard
agent-dashboard load "my-dashboard"
```

### Running a Workflow

```bash
# Run a defined workflow
agent-workflow run code-review --input src/

# List available workflows
agent-workflow list

# Create a new workflow interactively
agent-workflow create my-workflow
```

### Using the Agent Menu

```bash
# Open interactive agent menu (requires fzf or peco)
agent-menu

# Or use keybinding: <prefix> A
```

---

## Tmux Keybindings

- `<prefix> A` - Open agent menu
- `<prefix> C-a` - Quick agent access menu
- `<prefix> C-d` - Create default dashboard

---

## Status Line

The tmux status line shows:
- Active agent icon and name when in an agent session
- Dashboard icon and name when in a dashboard session

---

## Configuring New Agents

To add a new CLI tool as an agent, create a configuration file in `.agents/agents/<agent-name>.json`:

```json
{
  "name": "my-agent",
  "display_name": "My Agent",
  "command": "my-cli-tool",
  "default_args": ["--option", "value"],
  "working_dir": null,
  "env_vars": {},
  "session_prefix": "agent-",
  "icon": "🔧",
  "color": "blue"
}
```

---

## Workflows

Workflows are defined in YAML files in `.agents/workflows/`:

```yaml
name: my-workflow
description: My custom workflow
steps:
  - agent: aider
    name: first-step
    input: "${INPUT_DIR}"
  - agent: gpt-cli
    name: second-step
    input: "${aider:output}"
```

---

## Dashboard Layouts

Available layouts:
- `tiled` - Equal-sized panes in a grid
- `main-horizontal` - One large pane, others stacked below
- `main-vertical` - One large pane, others stacked to the right
- `even-horizontal` - Panes spread evenly horizontally
- `even-vertical` - Panes spread evenly vertically

---

## Requirements

For the agent menu:
- `fzf` (recommended) or `peco` must be installed

Install fzf:
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

---

## Troubleshooting

### Agent command not found

Make sure the CLI tool is installed and available in your PATH:
```bash
which aider  # Check if aider is installed
```

### Menu not opening

Ensure fzf or peco is installed:
```bash
which fzf  # Check if fzf is installed
```

### Session not found

The session might have been killed. Start it again:
```bash
agent-session start aider
```

---

## Getting Help

- `agent-session --help` - Agent session management help
- `agent-dashboard --help` - Dashboard management help
- `agent-workflow --help` - Workflow execution help
- `agent-menu --help` - Interactive menu help

---

## Full Documentation

See [AGENTS.md](AGENTS.md) for complete documentation.
