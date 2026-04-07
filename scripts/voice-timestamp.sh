#!/bin/bash
# Records timestamp when Claude starts using tools
# Called via PreToolUse hook — only writes on first tool call
START_FILE="/tmp/.claude-response-start"
[ ! -f "$START_FILE" ] && date +%s > "$START_FILE"
