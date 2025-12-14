#!/bin/bash

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
trigger=$(echo "$input" | jq -r '.trigger')
transcript_path=$(echo "$input" | jq -r '.transcript_path')
custom_instructions=$(echo "$input" | jq -r '.custom_instructions // ""')
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"

backup_dir="$HOME/.claude/compact-backups"
mkdir -p "$backup_dir"

context_file="$backup_dir/${session_id}.md"

{
  echo "# Compact Context Backup"
  echo ""
  echo "- Session: $session_id"
  echo "- Trigger: $trigger"
  echo "- Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "- Project: $project_dir"
  if [ -n "$custom_instructions" ] && [ "$custom_instructions" != "null" ]; then
    echo "- Custom Instructions: $custom_instructions"
  fi
  echo ""

  if [ -f "$transcript_path" ]; then
    echo "## Recent Activity Summary"
    echo ""
    echo "Recent messages from transcript:"
    echo ""
    tail -20 "$transcript_path" 2>/dev/null | jq -r '
      select(.type == "user" or .type == "assistant") |
      if .type == "user" then "User: " + (.message // .content // "[no content]")[:200]
      elif .type == "assistant" then "Assistant: " + (.message // .content // "[no content]")[:200]
      else empty end
    ' 2>/dev/null | tail -10
    echo ""
  fi

  if [ -f "$project_dir/.claude/current-task.md" ]; then
    echo "## Current Task"
    echo ""
    cat "$project_dir/.claude/current-task.md"
    echo ""
  fi

  if [ -f "$project_dir/.claude/todo.md" ]; then
    echo "## Todo List"
    echo ""
    cat "$project_dir/.claude/todo.md"
    echo ""
  fi

} > "$context_file"

latest_link="$backup_dir/latest-${project_dir//\//_}.md"
ln -sf "$context_file" "$latest_link" 2>/dev/null

exit 0
