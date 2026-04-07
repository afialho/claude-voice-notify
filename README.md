# Claude Voice Notify

Voice + banner notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Get spoken alerts with the **project name** when Claude finishes a task or needs your input — so you always know which terminal to switch to.

## How it works

- **Voice**: macOS `say` speaks the project name + a short status phrase (e.g. *"myapp. Done."*)
- **Banner**: macOS notification banner shows project name and status
- **Smart timing**: Only notifies if Claude worked for 15+ seconds (configurable)

## Install

```bash
git clone https://github.com/afialho/claude-voice-notify.git
cd claude-voice-notify
./install.sh
```

Restart Claude Code after installing.

### Requirements

- macOS (uses native `say` command)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (installed automatically via Homebrew)

## Uninstall

```bash
cd claude-voice-notify
./uninstall.sh
```

## Configuration

Set environment variables in your shell profile (`~/.zshrc`, `~/.bashrc`):

| Variable | Default | Description |
|---|---|---|
| `CLAUDE_NOTIFY_THRESHOLD` | `15` | Minimum seconds of work before notifying |
| `CLAUDE_NOTIFY_VOICE` | `Samantha` | macOS voice (`say -v '?'` to list all) |
| `CLAUDE_NOTIFY_RATE` | `200` | Speech rate in words per minute |

### Example

```bash
# Use a different voice and notify after 30 seconds
export CLAUDE_NOTIFY_VOICE="Daniel"
export CLAUDE_NOTIFY_THRESHOLD=30
```

### Available voices (English)

```bash
say -v '?' | grep en_
```

Popular choices: `Samantha`, `Daniel`, `Karen`, `Moira`, `Alex`

## What gets installed

- `~/.claude/scripts/voice-notify.sh` — notification logic
- `~/.claude/scripts/voice-timestamp.sh` — tracks when Claude starts working
- Hooks added to `~/.claude/settings.json`:
  - `PreToolUse` — records start timestamp
  - `Stop` — speaks "done" notification
  - `Notification` — speaks "waiting" notification

## License

MIT
