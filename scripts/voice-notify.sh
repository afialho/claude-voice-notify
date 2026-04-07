#!/bin/bash
# Voice + banner notification for Claude Code
# Speaks project name + status when Claude finishes or needs input
# Only triggers if Claude worked for >= NOTIFY_THRESHOLD seconds

START_FILE="/tmp/.claude-response-start"
NOTIFY_THRESHOLD="${CLAUDE_NOTIFY_THRESHOLD:-15}"
NOTIFY_VOICE="${CLAUDE_NOTIFY_VOICE:-Samantha}"
NOTIFY_RATE="${CLAUDE_NOTIFY_RATE:-200}"

if [ "${1:-done}" = "done" ]; then
    [ ! -f "$START_FILE" ] && exit 0
    ELAPSED=$(( $(date +%s) - $(cat "$START_FILE") ))
    rm -f "$START_FILE"
    [ "$ELAPSED" -lt "$NOTIFY_THRESHOLD" ] && exit 0
fi

DONE=("Done." "All done." "Task complete." "Finished." "Ready.")
WAIT=("I need you." "Your input is needed." "Waiting for you.")

if [ "${1:-done}" = "waiting" ]; then
    PHRASES=("${WAIT[@]}")
else
    PHRASES=("${DONE[@]}")
fi

PROJECT=$(basename "$PWD")
MSG="${PHRASES[$((RANDOM % ${#PHRASES[@]}))]}"

# macOS banner notification (requires terminal-notifier)
if command -v terminal-notifier &>/dev/null; then
    terminal-notifier -title "Claude Code" -subtitle "$PROJECT" -message "$MSG" -ignoreDnD &
fi

# Voice notification (macOS say)
say -v "$NOTIFY_VOICE" -r "$NOTIFY_RATE" "$PROJECT. $MSG"
