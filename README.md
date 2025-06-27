# AI Workflow Tools Setup

This repository contains tools and configurations for setting up a multi-AI workflow environment using tmux sessions with synchronized panes.

## Quick Start

1. **Run the setup script:**

   ```bash
   chmod +x setup-ai-tools.sh
   ./setup-ai-tools.sh
   ```

   The script will:
   - Check for required dependencies
   - Install AI CLI tools (with your permission)
   - Configure API keys
   - Install tmux aliases automatically

2. **Reload your shell configuration:**

   ```bash
   source ~/.zshrc  # or ~/.bashrc, ~/.config/fish/config.fish
   ```

## What the Setup Script Does

The `setup-ai-tools.sh` script:

- ✅ **Checks prerequisites**: Verifies Node.js, npm, and tmux are installed
- 🔍 **Detects existing installations**: Checks if AI CLI tools are already installed
- 📦 **Installs CLI tools** (with user confirmation):
  - `@anthropic-ai/claude-code` - Claude CLI
  - `@google/gemini-cli` - Gemini CLI  
  - `@openai/codex` - Codex CLI (optional)
- 🔑 **Configures API keys**: Helps set up environment variables for each service
- 🐚 **Shell detection**: Automatically detects your shell (zsh/bash/fish) and uses the correct config file
- 📺 **Installs tmux aliases**: Checks for existing aliases and installs missing ones automatically
- ⚙️ **Configures tmux**: Sets up tmux.conf with optimized keybindings for AI workflows

## Required API Keys

To use the AI CLI tools, you'll need API keys from:

| Service | CLI Tool | API Key Variable | Get API Key From |
|---------|----------|------------------|------------------|
| Anthropic Claude | `claude` | `ANTHROPIC_API_KEY` | [console.anthropic.com](https://console.anthropic.com/) |
| Google Gemini | `gemini` | `GOOGLE_AI_API_KEY` | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) |
| OpenAI Codex | `codex` | `OPENAI_API_KEY` | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |

## Available Workflows

After setup, you can use these commands:

### Individual Commands

- `claude` - Start Claude CLI
- `gemini` - Start Gemini CLI  
- `codex` - Start Codex CLI (if installed)
- `yolo` - Claude with dangerous permissions enabled

### Tmux Workflow Sessions

- `ai` - Start synchronized session with Claude + Gemini + Terminal
- `reai` - Reconnect to the AI session
- `ai-yolo` - Start session with two Claude instances in "yolo" mode + Terminal
- `reai-yolo` - Reconnect to the yolo session
- `ai-demo` - Start demo session with Claude + Gemini + Codex
- `reai-demo` - Reconnect to the demo session

### Tmux Session Controls

Within synchronized tmux sessions:

- `Ctrl+s` or `Option+s` - Toggle input synchronization
- `Ctrl+a s` - Toggle sync using prefix key
- `Ctrl+a k` - Kill the current session
- Mouse support - Click to switch between panes
- Visual indicator - Red "SYNC ON" appears when panes are synchronized

**Note**: The setup script configures tmux with `Ctrl+a` as the prefix key (instead of default `Ctrl+b`)

## Manual Installation

If you prefer to install manually:

```bash
# Install CLI tools
npm install -g @anthropic-ai/claude-code
npm install -g @google/gemini-cli
npm install -g @openai/codex  # optional

# Add API keys to your shell config
echo 'export ANTHROPIC_API_KEY="your-key-here"' >> ~/.zshrc
echo 'export GOOGLE_AI_API_KEY="your-key-here"' >> ~/.zshrc
echo 'export OPENAI_API_KEY="your-key-here"' >> ~/.zshrc

# Create tmux configuration manually or run the setup script
# The setup script will create ~/.tmux.conf with optimized keybindings
```

## Troubleshooting

**Command not found after installation:**

- Restart your terminal or run `source ~/.zshrc`
- Check that npm global bin directory is in your PATH

**API key issues:**

- Verify keys are correctly set: `echo $ANTHROPIC_API_KEY`
- Make sure there are no extra spaces or quotes
- Try re-running the setup script to update keys

**Tmux session issues:**

- Install tmux if not available: `brew install tmux` (macOS) or `apt install tmux` (Linux)
- Kill stuck sessions: `tmux kill-session -t session-name` 