# CLI Agent Management System

Transform oh-my-tmux into a powerful CLI agent management system for efficiently managing multiple CLI tools (aider, cursor-cli, gpt-cli, anthropic-cli, and more).

---

## Project Overview

This system extends oh-my-tmux to provide a unified interface for managing multiple AI/CLI agents from within tmux. Each agent gets its own isolated session, while dashboards let you monitor multiple agents simultaneously.

### Why Use Tmux for Agent Management?

- **Unified Interface**: Manage all your CLI tools from one terminal
- **Persistent Sessions**: Agent sessions survive terminal restarts
- **Parallel Execution**: Run multiple agents side-by-side in panes
- **Status Monitoring**: Real-time status indicators in tmux status line
- **Workflow Orchestration**: Chain agents together for complex tasks

### Key Benefits

- **Agent Sessions**: Dedicated, isolated tmux sessions for each CLI agent
- **Agent Dashboard**: Multi-pane view monitoring multiple agents simultaneously with status indicators
- **Agent Workflows**: Chain multiple CLI agents together, passing outputs between them
- **Quick Switch**: Fast navigation between agents via keybindings and menus

---

## Core Features

### Agent Sessions

Each CLI agent runs in its own dedicated tmux session with:
- Isolated environment and working directory
- Customizable command-line arguments
- Persistent state across terminal sessions
- Easy start/stop/switch commands

**Example:**
```bash
agent-session start aider
# Creates tmux session "agent-aider" with aider running
```

### Agent Dashboard

Monitor multiple agents simultaneously with:
- Pre-configured layouts (2x2, 1x3, custom)
- Real-time status indicators per pane
- One-command dashboard creation
- Switch between agents without leaving dashboard

**Example:**
```bash
agent-dashboard create "my-dashboard" --agents aider,gpt-cli
# Creates side-by-side dashboard with 2 agents
```

### Agent Workflows

Chain multiple agents together for complex tasks:
- YAML workflow definitions
- Output passing between agents
- Reusable workflow templates
- Visual progress tracking

**Example:**
```bash
agent-workflow run code-review --input src/
# Chains aider → gpt-cli → anthropic-cli for review
```

### Quick Switch

Navigate between agents instantly:
- Interactive agent menu (fzf/peco)
- Custom keybindings for common agents
- Context-preserving session switches
- Status line shows active agents

**Example:**
```bash
agent-menu
# Interactive menu to select and switch agents
```

---

## Supported CLI Tools

The system is designed to work with any CLI tool, with pre-built configurations for:

- **aider** - AI pair programmer for coding
- **cursor-cli** - AI coding assistant
- **gpt-cli** - OpenAI GPT CLI tool
- **anthropic-cli** - Claude CLI tool
- **Custom Agents** - Add your own via JSON config

---

## Implementation Approach

### Directory Structure

```
.tmux/
├── AGENTS.md              # This documentation
├── .agents/               # Agent and workflow configs
│   ├── agents/            # Agent definitions (JSON)
│   ├── workflows/         # Workflow definitions (YAML)
│   └── layouts/           # Dashboard layouts (JSON)
├── bin/                   # Executable scripts
│   ├── agent-session      # Session management
│   ├── agent-dashboard    # Dashboard management
│   ├── agent-workflow     # Workflow execution
│   └── agent-menu         # Interactive menu
└── lib/                   # Shared libraries
    ├── agent-utils.sh     # Agent configuration utilities
    ├── tmux-helpers.sh    # Tmux session/layout helpers
    └── status-functions.sh # Status line integration
```

### Configuration Files

#### Agent Definitions (`.agents/agents/*.json`)

Each agent has a JSON configuration:

```json
{
  "name": "aider",
  "display_name": "Aider",
  "command": "aider",
  "default_args": ["--model", "gpt-4"],
  "working_dir": null,
  "env_vars": {},
  "session_prefix": "agent-",
  "icon": "🤖",
  "color": "green"
}
```

#### Workflow Definitions (`.agents/workflows/*.yml`)

Workflows define multi-agent pipelines:

```yaml
name: code-review
description: Chain multiple agents for comprehensive code review
steps:
  - agent: aider
    name: initial-analysis
    input: "${INPUT_DIR}"
  - agent: gpt-cli
    name: suggestions
    input: "${aider:output}"
  - agent: anthropic-cli
    name: final-summary
    input: "${gpt-cli:output}"
```

#### Dashboard Layouts (`.agents/layouts/*.json`)

Define reusable dashboard layouts:

```json
{
  "name": "2x2",
  "description": "Four pane grid layout",
  "layout": "tiled",
  "panes": 4
}
```

### Tmux Integration

#### Custom Keybindings

Added to `.tmux.conf.local`:

```bash
# Agent keybindings
bind A run-shell "$TMUX_CONF/../bin/agent-menu"
bind C-a new-session -n "agent-menu" "agent-menu"
bind C-d run-shell "$TMUX_CONF/../bin/agent-dashboard create default"
```

#### Status Line Integration

Custom status functions show active agents:

```bash
tmux_conf_theme_status_right="#{agent_status} , %R , %d %b | ..."
```

---

## Usage Examples

### Starting an Agent Session

```bash
# Start aider in new session
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
# Open interactive agent menu
agent-menu

# Or use keybinding: <prefix> A
```

The menu shows:
- All configured agents
- Running status
- Quick actions (start/stop/switch)

---

## Shell Scripts Reference

### `bin/agent-session`

Manage individual agent sessions.

**Commands:**
- `start <agent-name> [--args "..."]` - Start new agent session
- `stop <agent-name>` - Stop agent session
- `list` - List all agent sessions
- `switch <agent-name>` - Switch to agent session
- `status <agent-name>` - Get agent status

### `bin/agent-dashboard`

Create and manage multi-agent dashboards.

**Commands:**
- `create <name> --agents <agent1,agent2,...> [--layout <layout>]` - Create dashboard
- `list` - List saved dashboards
- `load <name>` - Load a dashboard
- `save <name>` - Save current layout as dashboard

### `bin/agent-workflow`

Execute and manage agent workflows.

**Commands:**
- `run <workflow-name> [--param value]` - Execute workflow
- `list` - List available workflows
- `create <name>` - Create new workflow
- `validate <workflow-name>` - Validate workflow syntax

### `bin/agent-menu`

Interactive agent selection menu.

**Features:**
- fzf/peco integration
- Agent status display
- Quick actions
- Search/filter agents

---

## Library Files Reference

### `lib/agent-utils.sh`

Agent configuration and validation utilities.

**Functions:**
- `get_agent_config <agent-name>` - Load agent config from JSON
- `validate_agent <agent-name>` - Check if agent command exists
- `list_available_agents` - Return all available agents
- `get_agent_session_name <agent-name>` - Get tmux session name for agent

### `lib/tmux-helpers.sh`

Tmux session and layout management.

**Functions:**
- `tmux_create_session <name> <command> [args]` - Create tmux session
- `tmux_create_dashboard <name> <layout> <agents>` - Create multi-pane layout
- `tmux_agent_status <agent-name>` - Get status of running agent
- `tmux_switch_session <session-name>` - Switch to session
- `tmux_kill_session <session-name>` - Kill session

### `lib/status-functions.sh`

Tmux status line integration functions.

**Custom Variables:**
- `#{agent_status}` - Formatted status of all active agents
- `#{active_agent}` - Currently active agent in session

**Functions:**
- `agent_status()` - Generate status string for status line
- `active_agent()` - Return current active agent name

---

## Installation

1. Clone this repository (already done if you're reading this)
2. Ensure tmux is running oh-my-tmux
3. The agent management system is ready to use
4. Optional: Install fzf or peco for enhanced menu functionality

```bash
# Install fzf (recommended)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

---

## Roadmap

### Phase 1: Core Management ✅
- [x] Agent session management
- [x] Basic dashboard creation
- [x] Status line integration

### Phase 2: Enhanced Features
- [ ] Advanced workflow orchestration
- [ ] Workflow templates
- [ ] Agent profiles/configurations
- [ ] Output capture and passing

### Phase 3: Advanced Integrations
- [ ] tmux-resurrect integration (persist agent state)
- [ ] tmux-continuum integration (auto-start agents)
- [ ] Remote agent management (via SSH)
- [ ] Agent performance monitoring

### Phase 4: UI Enhancements
- [ ] Visual workflow editor
- [ ] Dashboard customization UI
- [ ] Agent output filtering/highlighting
- [ ] Notification system

---

## Contributing

To add support for a new CLI agent:

1. Create `.agents/agents/<agent-name>.json` with agent configuration
2. Test with `agent-session start <agent-name>`
3. Create workflow examples if applicable
4. Update this documentation

---

## License

This agent management system is dual licensed under the WTFPL v2 license and the MIT license, following the oh-my-tmux project.

---

## Support

For issues or feature requests, please open an issue on the oh-my-tmux GitHub repository.
