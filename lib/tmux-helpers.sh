#!/bin/bash
# Tmux Session and Layout Helpers
# Helper functions for creating and managing tmux sessions for agents

# Create a new tmux session for an agent
tmux_create_session() {
  local session_name=$1
  local command=$2
  shift 2
  local args=("$@")

  # Create session with command in first pane
  tmux new-session -d -s "$session_name" -n "agent" "$command ${args[*]}" 2>/dev/null
  return $?
}

# Create a multi-pane dashboard layout
tmux_create_dashboard() {
  local dashboard_name=$1
  local layout=$2
  shift 2
  local agents=("$@")

  local session_name="dashboard-${dashboard_name}"

  # Check if session already exists
  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Dashboard session already exists: $session_name"
    return 1
  fi

  # Source agent utilities
  local tmux_dir
  tmux_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "${tmux_dir}/lib/agent-utils.sh"

  # Create initial session with first agent
  local first_agent=${agents[0]}
  if ! validate_agent "$first_agent"; then
    echo "Error: Invalid agent: $first_agent"
    return 1
  fi

  local command
  local default_args
  local working_dir
  command=$(get_agent_command "$first_agent")
  default_args=$(get_agent_default_args "$first_agent")
  working_dir=$(get_agent_working_dir "$first_agent")

  local full_command="$command $default_args"
  local create_args=()

  if [[ -n "$working_dir" ]]; then
    create_args=("-c" "$working_dir")
  fi

  tmux new-session -d -s "$session_name" -n "$first_agent" $create_args "$full_command"

  # Split panes for additional agents
  local agent_count=${#agents[@]}

  if [[ $agent_count -gt 1 ]]; then
    # Determine split direction based on layout
    local split_cmd="split-window -h"

    # Create panes for remaining agents
    for ((i=1; i<agent_count; i++)); do
      local agent=${agents[$i]}

      if ! validate_agent "$agent"; then
        echo "Warning: Skipping invalid agent: $agent"
        continue
      fi

      command=$(get_agent_command "$agent")
      default_args=$(get_agent_default_args "$agent")
      working_dir=$(get_agent_working_dir "$agent")
      full_command="$command $default_args"

      if [[ -n "$working_dir" ]]; then
        tmux $split_cmd -c "$working_dir" "$full_command"
      else
        tmux $split_cmd "$full_command"
      fi

      # Alternate split direction for tiled layouts
      if [[ "$layout" == "tiled" ]]; then
        if [[ $split_cmd == *" -h"* ]]; then
          split_cmd="split-window -v"
        else
          split_cmd="split-window -h"
        fi
      fi
    done

    # Apply layout if specified
    if [[ "$layout" != "default" ]]; then
      tmux select-layout -t "$session_name" "$layout"
    fi
  fi

  echo "Dashboard created: $session_name"
  return 0
}

# Get status of a running agent session
tmux_agent_status() {
  local agent_name=$1

  # Source agent utilities
  local tmux_dir
  tmux_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "${tmux_dir}/lib/agent-utils.sh"

  local session_name
  session_name=$(get_agent_session_name "$agent_name") || return 1

  if ! is_agent_session_running "$agent_name"; then
    echo "stopped"
    return 1
  fi

  # Check if any panes are running the agent command
  local command
  command=$(get_agent_command "$agent_name")
  local panes
  panes=$(tmux list-panes -t "$session_name" -F '#{pane_current_command}' 2>/dev/null)

  if echo "$panes" | grep -q "$command"; then
    echo "running"
  else
    echo "active"
  fi
}

# Switch to an agent session
tmux_switch_session() {
  local session_name=$1

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Error: Session not found: $session_name" >&2
    return 1
  fi

  # If inside tmux, switch session
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session_name"
  else
    # If outside tmux, attach to session
    tmux attach-session -t "$session_name"
  fi
}

# Kill an agent session
tmux_kill_session() {
  local session_name=$1

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Session not found: $session_name"
    return 1
  fi

  tmux kill-session -t "$session_name"
  echo "Session killed: $session_name"
}

# List all agent sessions
tmux_list_agent_sessions() {
  # Source agent utilities
  local tmux_dir
  tmux_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "${tmux_dir}/lib/agent-utils.sh"

  local sessions
  sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

  for session in $sessions; do
    if [[ $session == agent-* ]]; then
      local agent_name=${session#agent-}
      local status
      status=$(tmux_agent_status "$agent_name" 2>/dev/null || echo "stopped")
      local icon
      icon=$(get_agent_icon "$agent_name" 2>/dev/null || echo "🤖")
      echo "$session|$icon $agent_name|$status"
    fi
  done
}

# List all dashboard sessions
tmux_list_dashboard_sessions() {
  local sessions
  sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)

  for session in $sessions; do
    if [[ $session == dashboard-* ]]; then
      local panes
      panes=$(tmux list-panes -t "$session" -F '#W' 2>/dev/null | wc -l)
      echo "$session|$panes agents"
    fi
  done
}
