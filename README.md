# Claude Voice Notify

Voice + banner notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Get spoken alerts with the **project name** when Claude finishes a task or needs your input — so you always know which terminal to switch to.

## How it works

- **Voice**: speaks the project name + a short status phrase (e.g. *"myapp. Done."*)
- **Banner**: OS notification banner shows project name and status
- **Smart timing**: only notifies if Claude worked for 15+ seconds (configurable)

## Install

```bash
npx claude-voice-notify
```

Restart Claude Code after installing.

> You can also clone and run directly:
> ```bash
> git clone https://github.com/afialho/claude-voice-notify.git
> cd claude-voice-notify && ./install.sh
> ```

## Uninstall

```bash
npx claude-voice-notify uninstall
```

## Platform support

| | Voice | Banner |
|---|---|---|
| **macOS** | `say` (built-in) | `terminal-notifier` (auto-installed via Homebrew) |
| **Linux** | `spd-say`, `espeak`, or `espeak-ng` | `notify-send` |
| **Windows** | `System.Speech` (built-in) | Toast notifications (built-in) |

### Linux dependencies

```bash
# Voice (pick one)
sudo apt install speech-dispatcher   # spd-say
sudo apt install espeak-ng           # espeak-ng

# Banner
sudo apt install libnotify-bin       # notify-send
```

### Windows

No extra dependencies — uses built-in PowerShell APIs for both voice and notifications.

## Configuration

Set environment variables in your shell profile (`~/.zshrc`, `~/.bashrc`, or Windows System Environment):

| Variable | Default | Description |
|---|---|---|
| `CLAUDE_NOTIFY_THRESHOLD` | `15` | Minimum seconds of work before notifying |
| `CLAUDE_NOTIFY_VOICE` | `Samantha` (macOS) | Voice name (`say -v '?'` to list on macOS) |
| `CLAUDE_NOTIFY_RATE` | `200` (macOS/Linux) / `2` (Windows) | Speech rate |

### Example

```bash
export CLAUDE_NOTIFY_VOICE="Daniel"
export CLAUDE_NOTIFY_THRESHOLD=30
```

## What gets installed

- `~/.claude/scripts/voice-notify.{sh,ps1}` — notification logic
- `~/.claude/scripts/voice-timestamp.{sh,ps1}` — tracks when Claude starts working
- Hooks added to `~/.claude/settings.json`:
  - `PreToolUse` — records start timestamp
  - `Stop` — speaks "done" notification
  - `Notification` — speaks "waiting" notification

No global packages or daemons — just two scripts and three hook entries.

## License

MIT
