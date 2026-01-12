#!/bin/bash
# Tmux Status Line Integration Functions
# These functions provide custom variables for tmux status line

# Get status of all active agents for status line
agent_status() {
  local tmux_dir
  tmux_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "${tmux_dir}/lib/agent-utils.sh"
  source "${tmux_dir}/lib/tmux-helpers.sh"

  local agent_sessions
  agent_sessions=$(tmux_list_agent_sessions 2>/dev/null)

  if [[ -z "$agent_sessions" ]]; then
    return 0
  fi

  local status_parts=()

  while IFS='|' read -r session_name agent_display status; do
    local agent_name=${session_name#agent-}
    local icon
    icon=$(get_agent_icon "$agent_name")

    if [[ "$status" == "running" ]]; then
      status_parts+=("$icon")
    elif [[ "$status" == "active" ]]; then
      status_parts+=("$icon⚡")
    fi
  done <<< "$agent_sessions"

  if [[ ${#status_parts[@]} -gt 0 ]]; then
    echo "${status_parts[*]}"
  fi
}

# Get the currently active agent name
active_agent() {
  local current_session
  current_session=$(tmux display-message -p '#S')

  if [[ $current_session == agent-* ]]; then
    local agent_name=${current_session#agent-}
    local tmux_dir
    tmux_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    source "${tmux_dir}/lib/agent-utils.sh"

    local icon
    icon=$(get_agent_icon "$agent_name")
    echo "$icon $agent_name"
  elif [[ $current_session == dashboard-* ]]; then
    echo "📊 ${current_session#dashboard-}"
  fi
}

# Get count of running agents
agent_count() {
  local tmux_dir
  tmux_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  source "${tmux_dir}/lib/agent-utils.sh"

  local sessions
  sessions=$(tmux_list_agent_sessions 2>/dev/null)
  if [[ -z "$sessions" ]]; then
    echo "0"
    return
  fi

  local count=0
  while IFS='|' read -r session_name agent_display status; do
    if [[ "$status" == "running" || "$status" == "active" ]]; then
      ((count++))
    fi
  done <<< "$sessions"

  echo "$count"
}
