# Tmux Aliases for AI Workflows

This document outlines the tmux aliases configured for managing AI-related workflows, allowing for synchronized multi-pane sessions.

## Aliases

### `ai`

Starts a new tmux session named `ai-session` with three horizontal panes:
1.**Claude**: Runs the `claude` command.
2.**Gemini**: Runs the `gemini` command.
3.**Terminal**: A regular Zsh terminal.

All panes are synchronized for input, and the layout is evenly distributed horizontally.

To start: `ai`
To reconnect: `reai`

### `ai-yolo`

Starts a new tmux session named `ai-yolo-session` with three horizontal panes:
1.**Yolo**: Runs the `yolo` alias (which executes `claude --dangerously-skip-permissions`).
2.**Yolo**: Runs the `yolo` alias again.
3.**Terminal**: A regular Zsh terminal.

All panes are synchronized for input, and the layout is evenly distributed horizontally.

To start: `ai-yolo`
To reconnect: `reai-yolo`

### `ai-trinity`

Starts a new tmux session named `ai-trinity-session` with three horizontal panes:
1.**Claude**: Runs the `claude` command.
2.**Gemini**: Runs the `gemini` command.
3.**Codex**: Runs the `codex` command.

All panes are synchronized for input, and the layout is evenly distributed horizontally.

To start: `ai-trinity`
To reconnect: `reai-trinity`

## Reconnection Aliases

- `reai`: Attaches to the `ai-session` tmux session.
- `reai-yolo`: Attaches to the `ai-yolo-session` tmux session.
- `reai-trinity`: Attaches to the `ai-trinity-session` tmux session.

## Keybindings for Tmux Sessions

Within any of these synchronized tmux sessions:

- `Ctrl+s` or `Option+s`: Toggle input synchronization for panes.
- `Ctrl+a k`: Kill the current tmux session.
