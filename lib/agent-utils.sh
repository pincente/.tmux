#!/bin/bash
# Agent Management Utilities
# Helper functions for loading and validating agent configurations

# Get the base directory of the tmux configuration
get_tmux_dir() {
  echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

# Get the agents configuration directory
get_agents_dir() {
  echo "$(get_tmux_dir)/.agents/agents"
}

# Load agent configuration from JSON
get_agent_config() {
  local agent_name=$1
  local agents_dir
  agents_dir=$(get_agents_dir)
  local config_file="$agents_dir/${agent_name}.json"

  if [[ ! -f "$config_file" ]]; then
    echo "Error: Agent configuration not found: $config_file" >&2
    return 1
  fi

  # Return the config file path (will be parsed by calling script)
  echo "$config_file"
}

# Validate that an agent command exists and is executable
validate_agent() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  # Extract command from JSON using grep/awk (simpler than jq dependency)
  local command
  command=$(grep -o '"command":[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)

  if [[ -z "$command" ]]; then
    echo "Error: No command defined for agent: $agent_name" >&2
    return 1
  fi

  # Check if command exists
  if ! command -v "$command" &> /dev/null; then
    echo "Error: Agent command not found: $command" >&2
    echo "Please install $command to use this agent" >&2
    return 1
  fi

  return 0
}

# List all available agents
list_available_agents() {
  local agents_dir
  agents_dir=$(get_agents_dir)

  if [[ ! -d "$agents_dir" ]]; then
    return 1
  fi

  for config_file in "$agents_dir"/*.json; do
    if [[ -f "$config_file" ]]; then
      local agent_name
      agent_name=$(basename "$config_file" .json)
      echo "$agent_name"
    fi
  done
}

# Get agent session name
get_agent_session_name() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  # Extract session prefix from JSON
  local prefix
  prefix=$(grep -o '"session_prefix":[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)
  prefix=${prefix:-"agent-"}

  echo "${prefix}${agent_name}"
}

# Get agent command from config
get_agent_command() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  local command
  command=$(grep -o '"command":[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)
  echo "$command"
}

# Get agent default args from config
get_agent_default_args() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  # Extract default_args array - this is a simple extraction
  local args
  args=$(grep -oP '(?<="default_args":\s*\[)[^\]]*' "$config_file" | tr ',' ' ')
  echo "$args"
}

# Get agent working directory from config
get_agent_working_dir() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  local working_dir
  working_dir=$(grep -o '"working_dir":[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)

  # Return empty if null
  if [[ "$working_dir" == "null" || -z "$working_dir" ]]; then
    echo ""
  else
    echo "$working_dir"
  fi
}

# Get agent display name
get_agent_display_name() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  local display_name
  display_name=$(grep -o '"display_name":[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)
  echo "${display_name:-$agent_name}"
}

# Get agent icon
get_agent_icon() {
  local agent_name=$1
  local config_file
  config_file=$(get_agent_config "$agent_name") || return 1

  local icon
  icon=$(grep -o '"icon":[[:space:]]*"[^"]*"' "$config_file" | cut -d'"' -f4)
  echo "${icon:-🤖}"
}

# Check if agent session is running
is_agent_session_running() {
  local agent_name=$1
  local session_name
  session_name=$(get_agent_session_name "$agent_name") || return 1

  tmux has-session -t "$session_name" 2>/dev/null
  return $?
}
