#!/bin/bash

# AI Tools Setup Script
# Sets up Claude, Gemini, and optionally Codex CLI tools with API keys

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to ask yes/no questions
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if npm package is installed globally
npm_package_installed() {
    npm list -g --depth=0 "$1" >/dev/null 2>&1
}

# Function to detect shell
detect_shell() {
    # First check the user's login shell (more reliable)
    if [ -n "$SHELL" ]; then
        case "$SHELL" in
            */zsh) echo "zsh" ;;
            */bash) echo "bash" ;;
            */fish) echo "fish" ;;
            */sh) echo "sh" ;;
            *) 
                # If SHELL doesn't match known patterns, check version variables
                if [ -n "$ZSH_VERSION" ]; then
                    echo "zsh"
                elif [ -n "$BASH_VERSION" ]; then
                    echo "bash"
                else
                    echo "unknown"
                fi
                ;;
        esac
    else
        # Fallback to version checks if SHELL is not set
        if [ -n "$ZSH_VERSION" ]; then
            echo "zsh"
        elif [ -n "$BASH_VERSION" ]; then
            echo "bash"
        else
            echo "unknown"
        fi
    fi
}

# Function to get shell config file
get_shell_config() {
    local shell_type=$(detect_shell)
    case "$shell_type" in
        zsh) 
            echo "$HOME/.zshrc" 
            ;;
        bash) 
            # On macOS, .bash_profile is often used instead of .bashrc
            if [[ "$OSTYPE" == "darwin"* ]] && [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish) 
            echo "$HOME/.config/fish/config.fish" 
            ;;
        sh) 
            echo "$HOME/.profile" 
            ;;
        *) 
            # Default to .profile for unknown shells
            echo "$HOME/.profile" 
            ;;
    esac
}

# Function to add environment variable to shell config
add_to_shell_config() {
    local var_name="$1"
    local var_value="$2"
    local config_file=$(get_shell_config)
    local shell_type=$(detect_shell)
    
    # Format the export line based on shell type
    local export_line
    local search_pattern
    if [ "$shell_type" = "fish" ]; then
        export_line="set -x $var_name \"$var_value\""
        search_pattern="^set -x $var_name "
    else
        export_line="export $var_name=\"$var_value\""
        search_pattern="^export $var_name="
    fi
    
    # Check if variable already exists
    if grep -q "$search_pattern" "$config_file" 2>/dev/null; then
        print_warning "$var_name already exists in $config_file"
        if ask_yes_no "Do you want to update it?"; then
            # Use sed to replace the line
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "/$search_pattern/c\\
$export_line" "$config_file"
            else
                # Linux
                sed -i "/$search_pattern/c\\$export_line" "$config_file"
            fi
            print_success "Updated $var_name in $config_file"
        fi
    else
        # Create config directory for fish if it doesn't exist
        if [ "$shell_type" = "fish" ]; then
            mkdir -p "$(dirname "$config_file")"
        fi
        echo "$export_line" >> "$config_file"
        print_success "Added $var_name to $config_file"
    fi
}

# Function to check if alias exists
alias_exists() {
    local alias_name="$1"
    local config_file=$(get_shell_config)
    local shell_type=$(detect_shell)
    
    # First check if alias is active in current shell (most reliable)
    if command -v alias >/dev/null 2>&1; then
        alias "$alias_name" >/dev/null 2>&1 && return 0
    fi
    
    # Check main config file
    if [ "$shell_type" = "fish" ]; then
        grep -q "^alias $alias_name " "$config_file" 2>/dev/null || grep -q "^function $alias_name" "$config_file" 2>/dev/null
    else
        grep -q "^alias $alias_name=" "$config_file" 2>/dev/null
    fi && return 0
    
    # Check common alias files
    local alias_files=("$HOME/.aliases" "$HOME/.alias" "$HOME/.bash_aliases")
    for file in "${alias_files[@]}"; do
        if [ -f "$file" ]; then
            grep -q "^alias $alias_name=" "$file" 2>/dev/null && return 0
        fi
    done
    
    return 1
}

# Function to add alias to shell config
add_alias_to_config() {
    local alias_name="$1"
    local alias_command="$2"
    local config_file="${3:-$(get_shell_config)}"  # Use provided file or default to shell config
    local shell_type=$(detect_shell)
    
    if alias_exists "$alias_name"; then
        print_warning "Alias '$alias_name' already exists in $config_file"
        return 1
    fi
    
    # Format the alias based on shell type
    local alias_line
    if [ "$shell_type" = "fish" ]; then
        alias_line="alias $alias_name '$alias_command'"
    else
        alias_line="alias $alias_name=\"$alias_command\""
    fi
    
    echo "$alias_line" >> "$config_file"
    print_success "Added alias '$alias_name' to $config_file"
    return 0
}

# Function to install tmux aliases
install_tmux_aliases() {
    echo
    print_status "📺 Setting up tmux aliases"
    local config_file=$(get_shell_config)
    
    # Check if user has a separate aliases file
    local alias_file=""
    if [ -f "$HOME/.aliases" ] && grep -q "source.*\.aliases" "$config_file" 2>/dev/null; then
        alias_file="$HOME/.aliases"
        print_status "Detected separate aliases file: $alias_file"
    elif [ -f "$HOME/.alias" ] && grep -q "source.*\.alias" "$config_file" 2>/dev/null; then
        alias_file="$HOME/.alias"
        print_status "Detected separate aliases file: $alias_file"
    else
        alias_file="$config_file"
    fi
    
    if ! command_exists tmux; then
        print_warning "tmux is not installed, skipping alias installation"
        return 1
    fi
    
    print_status "Checking existing aliases..."
    
    # Define alias names and commands using parallel arrays (compatible with older bash)
    local alias_names=(
        "yolo"
        "ai"
        "reai"
        "ai-yolo"
        "reai-yolo"
        "ai-demo"
        "reai-demo"
    )
    
    local alias_commands=(
        "claude --dangerously-skip-permissions"
        'tmux new-session -d -s ai-session \; send-keys "claude" C-m \; split-window -h \; send-keys "gemini" C-m \; split-window -h \; send-keys "zsh" C-m \; select-layout even-horizontal \; set-option -w synchronize-panes on \; attach-session -t ai-session'
        'tmux attach-session -t ai-session'
        'tmux new-session -d -s ai-yolo-session \; send-keys "yolo" C-m \; split-window -h \; send-keys "yolo" C-m \; split-window -h \; send-keys "zsh" C-m \; select-layout even-horizontal \; set-option -w synchronize-panes on \; attach-session -t ai-yolo-session'
        'tmux attach-session -t ai-yolo-session'
        'tmux new-session -d -s ai-demo-session \; send-keys "claude" C-m \; split-window -h \; send-keys "gemini" C-m \; split-window -h \; send-keys "codex" C-m \; select-layout even-horizontal \; set-option -w synchronize-panes on \; attach-session -t ai-demo-session'
        'tmux attach-session -t ai-demo-session'
    )
    
    # Check which aliases exist
    local missing_aliases=()
    local missing_commands=()
    local existing_aliases=()
    
    for i in "${!alias_names[@]}"; do
        local alias_name="${alias_names[$i]}"
        local alias_command="${alias_commands[$i]}"
        
        if alias_exists "$alias_name"; then
            existing_aliases+=("$alias_name")
        else
            missing_aliases+=("$alias_name")
            missing_commands+=("$alias_command")
        fi
    done
    
    # Report existing aliases
    if [ ${#existing_aliases[@]} -gt 0 ]; then
        print_success "Found existing aliases: ${existing_aliases[*]}"
    fi
    
    # Install missing aliases if any
    if [ ${#missing_aliases[@]} -gt 0 ]; then
        echo
        print_status "Missing aliases: ${missing_aliases[*]}"
        if ask_yes_no "Do you want to install the missing tmux aliases?"; then
            echo
            # Add comment to the appropriate file
            echo "# AI Workflow Aliases" >> "$alias_file"
            
            for i in "${!missing_aliases[@]}"; do
                add_alias_to_config "${missing_aliases[$i]}" "${missing_commands[$i]}" "$alias_file"
            done
            
            echo
            print_success "Aliases installed successfully to $alias_file!"
        fi
    else
        print_success "All tmux aliases are already installed!"
    fi
}

# Function to setup tmux configuration
setup_tmux_config() {
    if ! command_exists tmux; then
        return 0
    fi
    
    echo
    print_status "⚙️  Setting up tmux configuration"
    
    local tmux_config="$HOME/.tmux.conf"
    
    if [ -f "$tmux_config" ]; then
        print_success "tmux configuration already exists at $tmux_config"
        if ask_yes_no "Do you want to view the current configuration?"; then
            echo
            cat "$tmux_config"
            echo
        fi
        return 0
    fi
    
    print_warning "No tmux configuration found"
    if ask_yes_no "Do you want to install the recommended tmux configuration?"; then
        cat > "$tmux_config" << 'EOF'
# Change prefix from Ctrl+b to Ctrl+a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse support (click to switch panes)
set -g mouse on

# Toggle sync with 's' after prefix (Ctrl+a then s)
bind s setw synchronize-panes

# Direct sync toggle with Option+s (no prefix needed)
bind -n M-s setw synchronize-panes

# Direct sync toggle with Ctrl+s (alternative)
bind -n C-s setw synchronize-panes

# Kill session with 'k' after prefix (Ctrl+a then k)
bind k kill-session

# Show sync status in status bar
set -g status-right '#{?pane_synchronized,#[bg=red]SYNC ON,}'
EOF
        print_success "tmux configuration installed at $tmux_config"
        echo
        print_status "Configuration includes:"
        echo "  • Prefix changed from Ctrl+b to Ctrl+a"
        echo "  • Mouse support enabled"
        echo "  • Sync panes: Ctrl+s, Option+s, or Ctrl+a s"
        echo "  • Kill session: Ctrl+a k"
        echo "  • Visual sync indicator in status bar"
        echo
        print_status "Reload tmux config: tmux source-file ~/.tmux.conf"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Node.js and npm
    if ! command_exists node || ! command_exists npm; then
        print_error "Node.js and npm are required but not installed."
        print_status "Please install Node.js from https://nodejs.org/"
        return 1
    fi
    print_success "Node.js and npm are installed"
    
    # Check tmux
    if command_exists tmux; then
        print_success "tmux is installed"
    else
        print_error "tmux is required for the AI workflow aliases but not installed."
        print_status "Installation instructions:"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  macOS: brew install tmux"
        elif command_exists apt-get; then
            echo "  Ubuntu/Debian: sudo apt-get install tmux"
        elif command_exists yum; then
            echo "  RHEL/CentOS: sudo yum install tmux"
        elif command_exists pacman; then
            echo "  Arch Linux: sudo pacman -S tmux"
        else
            echo "  Please install tmux using your system's package manager"
        fi
        echo
        if ! ask_yes_no "Do you want to continue without tmux? (You won't be able to use the workflow aliases)"; then
            return 1
        fi
    fi
    
    return 0
}

# Install Claude CLI
install_claude() {
    print_status "Checking Claude CLI..."
    if command_exists claude || npm_package_installed "@anthropic-ai/claude-code"; then
        print_success "Claude CLI is already installed"
        return 0
    else
        print_warning "Claude CLI is not installed"
        if ask_yes_no "Do you want to install Claude CLI (@anthropic-ai/claude-code)?"; then
            print_status "Installing Claude CLI..."
            npm install -g @anthropic-ai/claude-code
            print_success "Claude CLI installed successfully"
            return 0
        fi
        return 1
    fi
}

# Install Gemini CLI
install_gemini() {
    print_status "Checking Gemini CLI..."
    if command_exists gemini || npm_package_installed "@google/gemini-cli"; then
        print_success "Gemini CLI is already installed"
        return 0
    else
        print_warning "Gemini CLI is not installed"
        if ask_yes_no "Do you want to install Gemini CLI (@google/gemini-cli)?"; then
            print_status "Installing Gemini CLI..."
            npm install -g @google/gemini-cli
            print_success "Gemini CLI installed successfully"
            return 0
        fi
        return 1
    fi
}

# Install Codex CLI
install_codex() {
    print_status "Checking Codex CLI..."
    if command_exists codex || npm_package_installed "@openai/codex"; then
        print_success "Codex CLI is already installed"
        return 0
    else
        print_warning "Codex CLI is not installed"
        if ask_yes_no "Do you want to install Codex CLI (@openai/codex)? (Optional)"; then
            print_status "Installing Codex CLI..."
            npm install -g @openai/codex
            print_success "Codex CLI installed successfully"
            return 0
        fi
        return 1
    fi
}

# Setup Anthropic API key
setup_anthropic_key() {
    if command_exists claude || npm_package_installed "@anthropic-ai/claude-code"; then
        echo
        print_status "Claude CLI requires an Anthropic API key"
        print_status "Get your API key from: https://console.anthropic.com/"
        if ask_yes_no "Do you want to set up your Anthropic API key now?"; then
            read -p "Enter your Anthropic API key: " -s anthropic_key
            echo
            if [ -n "$anthropic_key" ]; then
                add_to_shell_config "ANTHROPIC_API_KEY" "$anthropic_key"
                export ANTHROPIC_API_KEY="$anthropic_key"
            fi
        fi
    fi
}

# Setup Google AI API key
setup_google_key() {
    if command_exists gemini || npm_package_installed "@google/gemini-cli"; then
        echo
        print_status "Gemini CLI requires a Google AI API key"
        print_status "Get your API key from: https://aistudio.google.com/app/apikey"
        if ask_yes_no "Do you want to set up your Google AI API key now?"; then
            read -p "Enter your Google AI API key: " -s google_key
            echo
            if [ -n "$google_key" ]; then
                add_to_shell_config "GOOGLE_AI_API_KEY" "$google_key"
                export GOOGLE_AI_API_KEY="$google_key"
            fi
        fi
    fi
}

# Setup OpenAI API key
setup_openai_key() {
    if command_exists codex || npm_package_installed "@openai/codex"; then
        echo
        print_status "Codex CLI requires an OpenAI API key"
        print_status "Get your API key from: https://platform.openai.com/api-keys"
        if ask_yes_no "Do you want to set up your OpenAI API key now?"; then
            read -p "Enter your OpenAI API key: " -s openai_key
            echo
            if [ -n "$openai_key" ]; then
                add_to_shell_config "OPENAI_API_KEY" "$openai_key"
                export OPENAI_API_KEY="$openai_key"
            fi
        fi
    fi
}

# Display completion message and aliases
show_completion_message() {
    local shell_config=$(get_shell_config)
    
    echo
    print_success "🎉 Setup completed!"
    print_status "Please restart your terminal or run: source $shell_config"
    echo
    
    # Check if tmux is installed for the reminder
    if ! command_exists tmux; then
        print_warning "Remember: tmux is not installed!"
        print_status "You'll need to install tmux to use the workflow aliases below."
        echo
    fi
    
    print_status "Available aliases:"
    echo "  • yolo      - claude --dangerously-skip-permissions"
    echo "  • ai        - Start AI workflow with Claude + Gemini + Terminal"
    echo "  • reai      - Reconnect to AI session"
    echo "  • ai-yolo   - Start AI workflow with Yolo mode"
    echo "  • ai-demo   - Start demo session with Claude + Gemini + Codex"
    echo "  • reai-demo - Reconnect to demo session"
    echo
    
    # Add tmux keybinding information
    if command_exists tmux; then
        print_status "Tmux session controls:"
        echo "  • Ctrl+s or Option+s - Toggle input synchronization"
        echo "  • Ctrl+a k          - Kill the current session"
    fi
}

# Main setup function
main() {
    print_status "🚀 AI Tools Setup Script"
    echo "This script will help you set up Claude, Gemini, and optionally Codex CLI tools."
    echo

    # Check prerequisites
    if ! check_prerequisites; then
        exit 1
    fi
    echo

    # Install tools
    install_claude
    install_gemini
    install_codex

    # Configure API keys
    echo
    print_status "🔑 API Key Configuration"
    local detected_shell=$(detect_shell)
    local shell_config=$(get_shell_config)
    print_status "Detected shell: $detected_shell"
    print_status "Using config file: $shell_config"
    
    setup_anthropic_key
    setup_google_key
    setup_openai_key

    # Install tmux aliases
    install_tmux_aliases

    # Setup tmux configuration
    setup_tmux_config

    # Show completion message
    show_completion_message
}

# Run main function
main "$@" 