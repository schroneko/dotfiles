#!/bin/bash

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"

backup_dir="$HOME/.claude/compact-backups"

latest_link="$backup_dir/latest-${project_dir//\//_}.md"

context=""

if [ -f "$latest_link" ]; then
  context=$(cat "$latest_link")
elif [ -f "$backup_dir/${session_id}.md" ]; then
  context=$(cat "$backup_dir/${session_id}.md")
fi

if [ -n "$context" ]; then
  context_json=$(echo "$context" | jq -Rs .)
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $context_json
  }
}
EOF
fi

exit 0
