# Claude Workspace Tools

A comprehensive workspace setup for Claude Code with command extensions, multi-AI integration, and synchronized development workflows.

## 🚀 Quick Start

1. **Clone and setup:**

   ```bash
   git clone <this-repo>
   cd claude-workspace-tools
   chmod +x setup-ai-tools.sh
   ./setup-ai-tools.sh
   ```

2. **Reload your shell:**

   ```bash
   source ~/.zshrc  # or ~/.bashrc, ~/.config/fish/config.fish
   ```

3. **Start working:**

   ```bash
   ai          # Launch synchronized AI workflow
   claude      # Use Claude with enhanced commands
   /gemini     # Analyze large codebases
   ```

## 🏗️ System Architecture

### Extension Framework

The setup uses a scalable extension system for Claude Code commands:

```txt
claude-workspace-tools/
├── extensions/                    # Command extension repositories
│   ├── SuperClaude/              # Professional development framework (submodule)
│   ├── claude-sessions/          # Session management system (submodule)  
│   └── custom-commands/          # Workflow-specific commands
├── config/
│   ├── extensions.yaml           # Extension registry and metadata
│   └── enabled.yaml              # User's active extensions
└── setup-ai-tools.sh            # Enhanced installation script
```

### Available Extensions

| Extension | Commands | Description |
|-----------|----------|-------------|
| **SuperClaude** | 18+ | Professional development framework with specialized commands |
| **claude-sessions** | 6 | Advanced session management with persistence and context |
| **custom-commands** | 5 | Workflow tools for Gemini, Git worktrees, and visualization |

## 📦 What the Setup Script Does

The enhanced `setup-ai-tools.sh` script provides:

### Core AI Tools Installation

- ✅ **AI CLI Tools**: Claude, Gemini, Codex (with detection of existing installations)
- 🔑 **API Key Configuration**: Secure environment variable setup
- 🐚 **Shell Integration**: Auto-detects zsh/bash/fish and configures appropriately
- 📺 **Tmux Workflows**: Synchronized multi-AI sessions with custom keybindings

### Extension Framework

- 🔧 **Extension Management**: Modular installation of command packages
- 📊 **Status Detection**: Intelligent detection of existing installations
- 🎯 **Selective Installation**: Choose which extensions to install
- 🔄 **Configuration Sync**: Automatic enabled.yaml management

### Git Workflow Integration

- 🌳 **Worktree Scripts**: Advanced parallel development workflows
- 🔀 **PR-Only Workflow**: Enforced pull request development process

## 🔑 Required API Keys

| Service | CLI Tool | API Key Variable | Get API Key From |
|---------|----------|------------------|------------------|
| Anthropic Claude | `claude` | `ANTHROPIC_API_KEY` | [console.anthropic.com](https://console.anthropic.com/) |
| Google Gemini | `gemini` | `GOOGLE_AI_API_KEY` | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) |
| OpenAI Codex | `codex` | `OPENAI_API_KEY` | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| Background Tasks | `claude` | `ENABLE_BACKGROUND_TASKS` | Set to `1` to enable enhanced processing |

### 🔧 Background Tasks

The setup script automatically configures `ENABLE_BACKGROUND_TASKS=1` for enhanced Claude capabilities:
- ✅ Adds to shell config (bash/zsh/fish agnostic) for global availability
- ✅ Prevents duplicates if already configured

## 🛠️ Available Commands

### CLI Aliases

- `claude` - Enhanced Claude CLI with extensions
- `gemini` - Gemini CLI for large codebase analysis
- `codex` - OpenAI Codex CLI (optional)
- `yolo` - Claude with dangerous permissions enabled

### Claude Code Extensions

#### SuperClaude Commands (18+)

Development framework with specialized commands:
- `/build` - Universal project builder with stack templates
- `/review` - AI-powered code review with evidence-based recommendations
- `/deploy` - Application deployment with rollback capabilities
- `/analyze` - Multi-dimensional analysis (code, architecture, performance, security)
- `/test` - Comprehensive testing framework (e2e, integration, unit, visual, performance)
- `/troubleshoot` - Professional debugging with systematic approaches
- `/improve` - Enhancement & optimization with measurable outcomes
- And 11+ more specialized commands...

#### Session Management Commands (6)

Advanced session tracking and persistence:

- `/project:session-start [name]` - Start new development session
- `/project:session-update [notes]` - Add timestamped progress updates
- `/project:session-end` - End session with comprehensive summary
- `/project:session-current` - Show current session status
- `/project:session-list` - List all past sessions
- `/project:session-help` - Display help information

#### Custom Workflow Commands (5)

Specialized workflow tools:

- `/gemini` - Large codebase analysis using Gemini's massive context window
- `/worktree-start` - Create and setup git worktrees for focused development
- `/worktree-finish` - Complete development work and clean up worktrees
- `/parallel-worktrees` - Advanced parallel development workflow setup
- `/mermaid` - Generate Mermaid diagrams and visualizations

### Tmux Workflow Sessions

Multi-AI synchronized sessions:

- `ai` - Start synchronized session with Claude + Gemini + Terminal
- `reai` - Reconnect to the AI session
- `ai-yolo` - Start session with two Claude instances in "yolo" mode + Terminal
- `reai-yolo` - Reconnect to the yolo session
- `ai-trinity` - Start trinity session with Claude + Gemini + Codex
- `reai-trinity` - Reconnect to the trinity session

#### Tmux Session Controls

Within synchronized tmux sessions:

- `Ctrl+s` or `Option+s` - Toggle input synchronization
- `Ctrl+a s` - Toggle sync using prefix key
- `Ctrl+a k` - Kill the current session
- Mouse support - Click to switch between panes
- Visual indicator - Red "SYNC ON" appears when panes are synchronized

## 🔧 Extension Management

### Adding New Extensions

1. **Add to extensions.yaml:**

   ```yaml
   extensions:
     your-extension:
       repo: "https://github.com/user/claude-extension.git"
       description: "Description of your extension"
       installer: "install.sh"
       commands: 5
       categories: ["category1", "category2"]
   ```

2. **Add as submodule:**

   ```bash
   git submodule add https://github.com/user/claude-extension.git extensions/your-extension
   ```

3. **Update setup script:**
   Add installation function and detection logic to `setup-ai-tools.sh`

### Extension Structure

Each extension should provide:

- Command files (`.md` format for Claude Code)
- Installation script or manual setup instructions
- Clear documentation of provided commands
- Dependency information

## 🌟 Advanced Workflows

### Large Codebase Analysis with Gemini

```bash
# Analyze entire project structure
/gemini --all_files -p "Analyze project architecture and dependencies"

# Feature verification across multiple directories  
/gemini -p "@src/ @tests/ Check test coverage for authentication features"

# Security audit across codebase
/gemini -p "@src/ @api/ @middleware/ Identify potential security vulnerabilities"
```

### Git Worktree Parallel Development

```bash
# Start parallel development branches
/parallel-worktrees feature-name  # Creates feature-name-1, feature-name-2, feature-name-3

# Work in isolated environments
cd feature-name-1  # Test approach 1
cd feature-name-2  # Test approach 2  
cd feature-name-3  # Test approach 3

# Finish and merge best approach via PR
/worktree-finish   # Clean completion process
```

### Session-Driven Development

```bash
# Start tracked development session
/project:session-start "implement-user-auth"

# Update progress throughout development
/project:session-update "Completed user model and authentication logic"

# End with comprehensive summary
/project:session-end
```

## 🧠 Planning with o3

Enhance your development workflow with advanced AI planning capabilities using the Zen MCP Server.

### What is Zen MCP Server?

The [Zen MCP Server](https://github.com/BeehiveInnovations/zen-mcp-server) provides access to multiple AI models through Claude Code, including o3 for sophisticated planning and analysis tasks.

### Quick Setup

1. **Clone the Zen MCP Server:**

   ```bash
   cd /Users/gwi/01-projects/04-ai/
   git clone https://github.com/BeehiveInnovations/zen-mcp-server.git
   cd zen-mcp-server
   ./run-server.sh
   ```

2. **Configure API Keys (Required):**

   ```bash
   # Copy example configuration
   cp .env.example .env
   
   # Edit .env with your API keys (at least one required):
   nano .env
   ```

   Add your API keys to the `.env` file:

   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   OPENAI_API_KEY=your_openai_api_key_here
   OPENROUTER_API_KEY=your_openrouter_api_key_here
   DEFAULT_MODEL=auto
   ```

3. **Connect to Claude Code:**

   ```bash
   # Generate configuration
   ./run-server.sh -c
   
   # Add to Claude Code
   claude mcp add zen -s user -- /Users/gwi/01-projects/04-ai/zen-mcp-server/.zen_venv/bin/python /Users/gwi/01-projects/04-ai/zen-mcp-server/server.py
   ```

### Available Planning Tools

Once connected, you'll have access to advanced planning capabilities:

- **`/zen:planner`** - Interactive step-by-step planning with deep thinking modes
- **`/zen:consensus`** - Multi-model consensus for complex decisions  
- **`/zen:thinkdeep`** - Comprehensive investigation and reasoning
- **`/zen:chat`** - Access to o3 and other advanced models for analysis

### API Key Sources

| Service | API Key Location |
|---------|------------------|
| **OpenAI (o3, GPT-4)** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |
| **Google AI (Gemini)** | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) |
| **OpenRouter (Multiple Models)** | [openrouter.ai/keys](https://openrouter.ai/keys) |

### Example Usage

```bash
# Start Claude Code and use planning tools
claude

# Interactive planning session
/zen:planner "Plan a microservices migration for our monolith application"

# Multi-model consensus
/zen:consensus "Should we use GraphQL or REST for our new API?"

# Deep analysis with o3
/zen:chat "Analyze the architectural implications of this database schema change"
```

## 📋 Installation Options

### Full Installation (Recommended)

```bash
./setup-ai-tools.sh
# Select all extensions when prompted
```

### Selective Installation

```bash
./setup-ai-tools.sh
# Choose specific extensions:
# - SuperClaude: Professional development commands
# - claude-sessions: Session management  
# - custom-commands: Workflow tools
```

### Manual Installation

```bash
# Install CLI tools only
npm install -g @anthropic-ai/claude-code @google/gemini-cli

# Install specific extensions
cd extensions/SuperClaude && ./install.sh
cd extensions/claude-sessions && # manual setup
```

## 🚨 Troubleshooting

### Command not found after installation

```bash
# Restart terminal or reload shell
source ~/.zshrc

# Check npm global path
npm config get prefix
echo $PATH | grep npm
```

### API key issues

```bash
# Verify keys are set
echo $ANTHROPIC_API_KEY
echo $GOOGLE_AI_API_KEY

# Re-run setup to update keys
./setup-ai-tools.sh
```

### Extension installation failures

```bash
# Check submodule status
git submodule status

# Update submodules
git submodule update --init --recursive

# Verify extension detection
ls -la ~/.claude/commands/
```

### Tmux session issues

```bash
# Install tmux if missing
brew install tmux        # macOS
sudo apt install tmux   # Ubuntu/Debian

# Kill stuck sessions
tmux kill-session -t ai
tmux list-sessions
```

### YAML configuration corruption

```bash
# The setup script automatically fixes enabled.yaml corruption
# If manual fix needed:
cat > config/enabled.yaml << 'EOF'
enabled:
  - SuperClaude
  - claude-sessions
  - custom-commands
EOF
```

## 🔄 Updates and Maintenance

### Updating Extensions

```bash
# Update all submodules
git submodule update --remote

# Update specific extension
cd extensions/SuperClaude
git pull origin main
cd ../..
```

### Adding Custom Commands

1. Place `.md` files in `extensions/custom-commands/commands/`
2. Re-run setup script to install
3. Commands become available as `/your-command`

## 🎯 Best Practices

### Development Workflow

1. **Start with large codebase analysis**: Use `/gemini` to understand architecture
2. **Create isolated worktrees**: Use `/worktree-start` for feature development
3. **Track progress**: Use session management for complex features
4. **Review systematically**: Use `/review` for code quality checks
5. **Deploy safely**: Use `/deploy` with rollback capabilities

### Multi-AI Collaboration

1. **Use synchronized sessions**: `ai` command for parallel AI consultation
2. **Compare approaches**: Ask same question to Claude and Gemini simultaneously
3. **Leverage strengths**: Gemini for analysis, Claude for implementation
4. **Document decisions**: Session management tracks reasoning and outcomes

### Extension Management

1. **Regular updates**: Keep extensions current with `git submodule update`
2. **Selective enabling**: Only enable extensions you actively use
3. **Custom extensions**: Create project-specific command extensions
4. **Share improvements**: Contribute back to extension repositories

## 📖 Further Reading

- [SuperClaude Documentation](extensions/SuperClaude/README.md)
- [Claude Sessions Guide](extensions/claude-sessions/README.md)
- [Tmux Workflow Patterns](docs/tmux.md)
- [Git Worktree Best Practices](extensions/custom-commands/commands/parallel-worktrees.md)

## 🙏 Credits & Acknowledgments

This project integrates and builds upon several excellent open-source projects:

### **Core Extensions**

- **[SuperClaude](https://github.com/NomenAK/SuperClaude)** by [NomenAK](https://github.com/NomenAK)
  - Professional development framework with 18+ specialized commands
  - Advanced Claude Code configuration and command system
  - Evidence-based development methodology

- **[Claude Sessions](https://github.com/iannuttall/claude-sessions)** by [Ian Nuttall](https://github.com/iannuttall)
  - Advanced session management for Claude Code
  - Development progress tracking and context preservation
  - Session-driven development workflows

### **Workflow Tools**

- **[Git Worktree Scripts](https://github.com/tomups/worktrees-scripts)** by [tomups](https://github.com/tomups)
  - Advanced git worktree management and automation
  - Parallel development workflow support
  - PR-only development process enforcement

### **Additional Resources**

- **[Mermaid Command](https://github.com/steipete/agent-rules)** by [Peter Steinberger](https://github.com/steipete)
  - Diagram generation command for Claude Code
  - Part of the agent-rules project for AI development

### **AI CLI Tools**

- **[Claude CLI](https://github.com/anthropics/claude-code)** by [Anthropic](https://github.com/anthropics)
- **[Gemini CLI](https://www.npmjs.com/package/@google/gemini-cli)** by [Google](https://github.com/google)
- **[OpenAI Codex CLI](https://platform.openai.com/)** by [OpenAI](https://github.com/openai)

### **Special Thanks**

- The Claude Code team at Anthropic for creating an extensible AI development platform
- The open-source community for developing the tools and workflows this project builds upon
- Contributors to tmux, git, and other foundational tools that make these workflows possible

---

**License**: MIT | **Contributions**: Welcome | **Issues**: [GitHub Issues](../../issues)

**Repository**: `claude-workspace-tools` - A comprehensive Claude Code workspace with extensions and multi-AI integration
