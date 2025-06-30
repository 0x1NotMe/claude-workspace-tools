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

# Function to handle alias migrations
handle_alias_migrations() {
    local config_file=$(get_shell_config)
    
    # Check if user has a separate aliases file
    local alias_file=""
    if [ -f "$HOME/.aliases" ] && grep -q "source.*\.aliases" "$config_file" 2>/dev/null; then
        alias_file="$HOME/.aliases"
    elif [ -f "$HOME/.alias" ] && grep -q "source.*\.alias" "$config_file" 2>/dev/null; then
        alias_file="$HOME/.alias"
    else
        alias_file="$config_file"
    fi
    
    # Define migration mappings: old_name:new_name
    local migrations=(
        "ai-demo:ai-trinity"
        "reai-demo:reai-trinity"
    )
    
    local found_deprecated=false
    local deprecated_aliases=()
    
    # Check for deprecated aliases
    for migration in "${migrations[@]}"; do
        local old_name="${migration%:*}"
        local new_name="${migration#*:}"
        
        if grep -q "^alias $old_name=" "$alias_file" 2>/dev/null; then
            found_deprecated=true
            deprecated_aliases+=("$old_name -> $new_name")
        fi
    done
    
    if [ "$found_deprecated" = true ]; then
        echo
        print_warning "Found deprecated aliases in $alias_file:"
        for alias_info in "${deprecated_aliases[@]}"; do
            echo "  • $alias_info"
        done
        echo
        
        if ask_yes_no "Do you want to migrate these aliases to their new names?"; then
            for migration in "${migrations[@]}"; do
                local old_name="${migration%:*}"
                local new_name="${migration#*:}"
                
                if grep -q "^alias $old_name=" "$alias_file" 2>/dev/null; then
                    # Replace old alias name with new name, keeping the command
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        # macOS
                        sed -i '' "s/^alias $old_name=/alias $new_name=/" "$alias_file"
                    else
                        # Linux
                        sed -i "s/^alias $old_name=/alias $new_name=/" "$alias_file"
                    fi
                    print_success "Migrated: $old_name -> $new_name"
                fi
            done
            echo
        else
            print_status "Keeping existing aliases. Note: New aliases will be added alongside old ones."
        fi
    fi
}

# Function to clean up deprecated aliases
cleanup_deprecated_aliases() {
    local config_file=$(get_shell_config)
    
    # Check if user has a separate aliases file
    local alias_file=""
    if [ -f "$HOME/.aliases" ] && grep -q "source.*\.aliases" "$config_file" 2>/dev/null; then
        alias_file="$HOME/.aliases"
    elif [ -f "$HOME/.alias" ] && grep -q "source.*\.alias" "$config_file" 2>/dev/null; then
        alias_file="$HOME/.alias"
    else
        alias_file="$config_file"
    fi
    
    # List of deprecated aliases to remove
    local deprecated_aliases=(
        "ai-demo"
        "reai-demo"
    )
    
    local found_deprecated=false
    local existing_deprecated=()
    
    # Check for deprecated aliases
    for alias_name in "${deprecated_aliases[@]}"; do
        if grep -q "^alias $alias_name=" "$alias_file" 2>/dev/null; then
            found_deprecated=true
            existing_deprecated+=("$alias_name")
        fi
    done
    
    if [ "$found_deprecated" = true ]; then
        echo
        print_warning "Found deprecated aliases that should be removed:"
        for alias_name in "${existing_deprecated[@]}"; do
            echo "  • $alias_name"
        done
        
        if ask_yes_no "Do you want to remove these deprecated aliases?"; then
            for alias_name in "${existing_deprecated[@]}"; do
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    sed -i '' "/^alias $alias_name=/d" "$alias_file"
                else
                    # Linux
                    sed -i "/^alias $alias_name=/d" "$alias_file"
                fi
                print_success "Removed deprecated alias: $alias_name"
            done
            echo
        fi
    fi
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
        "ai-trinity"
        "reai-trinity"
    )
    
    local alias_commands=(
        "claude --dangerously-skip-permissions"
        'tmux new-session -d -s ai-session \; send-keys "claude" C-m \; split-window -h \; send-keys "gemini" C-m \; split-window -h \; send-keys "zsh" C-m \; select-layout even-horizontal \; set-option -w synchronize-panes on \; attach-session -t ai-session'
        'tmux attach-session -t ai-session'
        'tmux new-session -d -s ai-yolo-session \; send-keys "yolo" C-m \; split-window -h \; send-keys "yolo" C-m \; split-window -h \; send-keys "zsh" C-m \; select-layout even-horizontal \; set-option -w synchronize-panes on \; attach-session -t ai-yolo-session'
        'tmux attach-session -t ai-yolo-session'
        'tmux new-session -d -s ai-trinity-session \; send-keys "claude" C-m \; split-window -h \; send-keys "gemini" C-m \; split-window -h \; send-keys "codex" C-m \; select-layout even-horizontal \; set-option -w synchronize-panes on \; attach-session -t ai-trinity-session'
        'tmux attach-session -t ai-trinity-session'
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

# Install Git Worktree Scripts
install_worktree_scripts() {
    print_status "Checking Git Worktree Scripts..."
    
    local dest_dir="$HOME/.local/bin"
    local scripts=("wtadd.sh" "wtremove.sh" "wtclone.sh")
    local missing_scripts=()
    
    # Check if scripts exist
    for script in "${scripts[@]}"; do
        if [ ! -f "$dest_dir/$script" ]; then
            missing_scripts+=("$script")
        fi
    done
    
    # Check if git aliases exist
    local missing_aliases=()
    for script in "${scripts[@]}"; do
        local alias_name=$(basename "$script" .sh)
        if ! git config --global --get alias.$alias_name >/dev/null 2>&1; then
            missing_aliases+=("$alias_name")
        fi
    done
    
    if [ ${#missing_scripts[@]} -eq 0 ] && [ ${#missing_aliases[@]} -eq 0 ]; then
        print_success "Git Worktree Scripts are already installed"
        return 0
    fi
    
    print_warning "Git Worktree Scripts are not fully installed"
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        print_status "Missing scripts: ${missing_scripts[*]}"
    fi
    if [ ${#missing_aliases[@]} -gt 0 ]; then
        print_status "Missing git aliases: ${missing_aliases[*]}"
    fi
    
    if ask_yes_no "Do you want to install Git Worktree Scripts? (Enhances git workflow with bare repos)"; then
        print_status "Installing Git Worktree Scripts..."
        
        # Define the repository URL and destination directory
        local repo_url="https://github.com/tomups/worktrees-scripts.git"
        
        # Create the destination directory if it does not exist
        mkdir -p "$dest_dir"
        
        # Clone the repository into a temporary directory
        local temp_dir=$(mktemp -d)
        if ! git clone "$repo_url" "$temp_dir" 2>/dev/null; then
            print_error "Failed to clone worktree scripts repository"
            rm -rf "$temp_dir"
            return 1
        fi
        
        # Copy the shell scripts to the destination directory
        for script in "${scripts[@]}"; do
            if [ -f "$temp_dir/$script" ]; then
                cp "$temp_dir/$script" "$dest_dir/"
                chmod +x "$dest_dir/$script"
                print_success "Installed $script"
            else
                print_warning "Script $script not found in repository"
            fi
        done
        
        # Clean up the temporary directory
        rm -rf "$temp_dir"
        
        # Add git aliases for each script
        for script in "${scripts[@]}"; do
            local script_name=$(basename "$script" .sh)
            if [ -f "$dest_dir/$script" ]; then
                git config --global alias.$script_name "!$dest_dir/$script"
                print_success "Added git alias: git $script_name"
            fi
        done
        
        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            print_warning "$HOME/.local/bin is not in your PATH"
            if ask_yes_no "Do you want to add $HOME/.local/bin to your PATH?"; then
                add_to_shell_config "PATH" "\$HOME/.local/bin:\$PATH"
                export PATH="$HOME/.local/bin:$PATH"
                print_success "Added $HOME/.local/bin to PATH"
            fi
        fi
        
        print_success "Git Worktree Scripts installed successfully!"
        print_status "Available commands:"
        echo "  • git wtclone <url> [dir]  - Clone repo as bare with main worktree"
        echo "  • git wtadd <name> [branch] - Add new worktree"
        echo "  • git wtremove <name>      - Remove worktree and branch"
        echo
        print_status "More info: https://www.tomups.com/worktrees"
        return 0
    fi
    return 1
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
    echo "  • yolo         - claude --dangerously-skip-permissions"
    echo "  • ai           - Start AI workflow with Claude + Gemini + Terminal"
    echo "  • reai         - Reconnect to AI session"
    echo "  • ai-yolo      - Start AI workflow with Yolo mode"
    echo "  • ai-trinity   - Start trinity session with Claude + Gemini + Codex"
    echo "  • reai-trinity - Reconnect to trinity session"
    echo
    
    # Show installed extensions
    if [ -f "config/enabled.yaml" ] && [ -s "config/enabled.yaml" ]; then
        print_status "Installed Claude Extensions:"
        if grep -q "SuperClaude" config/enabled.yaml 2>/dev/null; then
            echo "  • SuperClaude - 18 specialized commands (/build, /review, /deploy, etc.)"
        fi
        if grep -q "claude-sessions" config/enabled.yaml 2>/dev/null; then
            echo "  • Claude Sessions - Session management (/project:session-start, etc.)"
        fi
        if grep -q "custom-commands" config/enabled.yaml 2>/dev/null; then
            echo "  • Custom Commands - Workflow tools (/gemini, /worktree-*, /mermaid)"
        fi
        echo
    fi
    
    # Add tmux keybinding information
    if command_exists tmux; then
        print_status "Tmux session controls:"
        echo "  • Ctrl+s or Option+s - Toggle input synchronization"
        echo "  • Ctrl+a k          - Kill the current session"
    fi
}

# Extension Framework Functions
rebuild_enabled_yaml() {
    local enabled_file="config/enabled.yaml"
    local temp_file=$(mktemp)
    
    # Start with clean YAML structure
    echo "enabled:" > "$temp_file"
    
    # Add unique extensions from current file (if it exists) and any new ones
    if [ -f "$enabled_file" ]; then
        # Extract existing extensions and sort uniquely
        grep "^  - " "$enabled_file" 2>/dev/null | sort -u >> "$temp_file" || true
    fi
    
    # Replace the file
    mv "$temp_file" "$enabled_file"
}

add_to_enabled_yaml() {
    local extension_name="$1"
    local enabled_file="config/enabled.yaml"
    
    # Check if extension is already in the file (exact match)
    if [ -f "$enabled_file" ] && grep -q "^  - $extension_name$" "$enabled_file" 2>/dev/null; then
        return 0  # Already exists
    fi
    
    # Create or append to temp list
    local temp_file=$(mktemp)
    echo "enabled:" > "$temp_file"
    
    # Add existing extensions
    if [ -f "$enabled_file" ]; then
        grep "^  - " "$enabled_file" 2>/dev/null >> "$temp_file" || true
    fi
    
    # Add new extension
    echo "  - $extension_name" >> "$temp_file"
    
    # Sort and deduplicate, then rebuild
    {
        echo "enabled:"
        grep "^  - " "$temp_file" | sort -u
    } > "$enabled_file"
    
    rm -f "$temp_file"
}

install_extension_framework() {
    print_status "Setting up extension framework..."
    
    # Create directories
    mkdir -p extensions config
    
    # Create extensions registry if it doesn't exist
    if [ ! -f "config/extensions.yaml" ]; then
        cat > config/extensions.yaml << 'EOF'
extensions:
  SuperClaude:
    repo: "https://github.com/NomenAK/SuperClaude.git"
    description: "Professional development framework with 18 specialized commands"
    installer: "install.sh"
    commands: 18
    categories: ["development", "analysis", "operations", "design"]
    
  claude-sessions:
    repo: "https://github.com/iannuttall/claude-sessions.git"
    description: "Advanced session management for Claude with persistence and context"
    installer: "manual"
    commands: 6
    categories: ["session", "management", "persistence"]
EOF
    fi
    
    # Create enabled extensions config
    if [ ! -f "config/enabled.yaml" ]; then
        echo "enabled: []" > config/enabled.yaml
    fi
}

is_superclaude_installed() {
    # Check for SuperClaude-specific files and commands
    [ -f "$HOME/.claude/CLAUDE.md" ] && \
    [ -d "$HOME/.claude/commands" ] && \
    [ -f "$HOME/.claude/commands/build.md" ] && \
    [ -f "$HOME/.claude/commands/review.md" ] && \
    [ -d "$HOME/.claude/shared" ]
}

install_superclaude() {
    local extension_dir="extensions/SuperClaude"
    
    if is_superclaude_installed; then
        print_success "SuperClaude is already installed"
        # Ensure it's marked as enabled
        add_to_enabled_yaml "SuperClaude"
        return 0
    fi
    
    print_status "Installing SuperClaude framework..."
    
    if [ -d "$extension_dir" ]; then
        cd "$extension_dir"
        if [ -f "install.sh" ]; then
            ./install.sh --force
            print_success "SuperClaude installed successfully"
            cd ../..
            add_to_enabled_yaml "SuperClaude"
        else
            print_error "SuperClaude installer not found"
        fi
        cd ../..
    else
        print_error "SuperClaude extension directory not found"
    fi
}

is_claude_sessions_installed() {
    # Check for session-specific commands
    [ -f "$HOME/.claude/commands/session-start.md" ] && \
    [ -f "$HOME/.claude/commands/session-end.md" ] && \
    [ -d "$HOME/.claude/sessions" ]
}

install_claude_sessions() {
    if is_claude_sessions_installed; then
        print_success "Claude Sessions is already installed"
        # Ensure it's marked as enabled
        add_to_enabled_yaml "claude-sessions"
        return 0
    fi
    
    print_status "Setting up Claude Sessions..."
    
    local extension_dir="extensions/claude-sessions"
    local claude_dir="$HOME/.claude"
    
    # Create Claude directories if they don't exist
    mkdir -p "$claude_dir/commands"
    mkdir -p "$claude_dir/sessions"
    
    # Copy command files and update paths
    if [ -d "$extension_dir/commands" ]; then
        for cmd in "$extension_dir/commands"/*.md; do
            if [ -f "$cmd" ]; then
                # Update paths in command files from sessions/ to .claude/sessions/
                sed 's|sessions/|.claude/sessions/|g' "$cmd" > "$claude_dir/commands/$(basename "$cmd")"
            fi
        done
        print_success "Claude Sessions commands installed"
    fi
    
    # Create session tracking file
    touch "$claude_dir/sessions/.current-session"
    
    # Optional: Add sessions/ to .gitignore
    if ask_yes_no "Add sessions to .gitignore for privacy?"; then
        echo ".claude/sessions/" >> .gitignore 2>/dev/null || true
    fi
    
    add_to_enabled_yaml "claude-sessions"
    print_success "Claude Sessions installed successfully!"
}

is_custom_commands_installed() {
    # Check for custom commands
    [ -f "$HOME/.claude/commands/gemini.md" ] && \
    [ -f "$HOME/.claude/commands/worktree-start.md" ] && \
    [ -f "$HOME/.claude/commands/mermaid.md" ]
}

install_custom_commands() {
    if is_custom_commands_installed; then
        print_success "Custom Commands are already installed"
        # Ensure it's marked as enabled
        add_to_enabled_yaml "custom-commands"
        return 0
    fi
    
    print_status "Setting up Custom Commands..."
    
    local extension_dir="extensions/custom-commands"
    local claude_dir="$HOME/.claude"
    
    # Create Claude directories if they don't exist
    mkdir -p "$claude_dir/commands"
    
    # Copy command files
    if [ -d "$extension_dir/commands" ]; then
        for cmd in "$extension_dir/commands"/*.md; do
            if [ -f "$cmd" ]; then
                cp "$cmd" "$claude_dir/commands/"
            fi
        done
        print_success "Custom commands installed: /gemini, /worktree-*, /parallel-worktrees, /mermaid"
    fi
    
    add_to_enabled_yaml "custom-commands"
    print_success "Custom Commands installed successfully!"
}

list_available_extensions() {
    print_status "Available extensions:"
    echo "  • SuperClaude - Professional development framework (18 commands)"
    echo "  • claude-sessions - Advanced session management (6 commands)"
    echo "  • custom-commands - Workflow commands: /gemini, /worktree-*, /mermaid (5 commands)"
}

check_extension_status() {
    echo
    print_status "🔍 Checking Extension Status"
    
    local superclaude_status="❌ Not installed"
    local sessions_status="❌ Not installed"  
    local custom_status="❌ Not installed"
    
    if is_superclaude_installed; then
        superclaude_status="✅ Installed"
    fi
    
    if is_claude_sessions_installed; then
        sessions_status="✅ Installed"
    fi
    
    if is_custom_commands_installed; then
        custom_status="✅ Installed"
    fi
    
    echo "  • SuperClaude:      $superclaude_status"
    echo "  • Claude Sessions:  $sessions_status"
    echo "  • Custom Commands:  $custom_status"
    echo
}

install_selected_extensions() {
    echo
    print_status "🔧 Claude Command Extensions Setup"
    
    install_extension_framework
    check_extension_status
    
    echo "Available extensions enhance Claude with specialized commands:"
    list_available_extensions
    echo
    
    if ! is_superclaude_installed && ask_yes_no "Install SuperClaude framework?"; then
        install_superclaude
    elif is_superclaude_installed; then
        install_superclaude  # Just updates enabled.yaml
    fi
    
    if ! is_claude_sessions_installed && ask_yes_no "Install Claude Sessions?"; then
        install_claude_sessions  
    elif is_claude_sessions_installed; then
        install_claude_sessions  # Just updates enabled.yaml
    fi
    
    if ! is_custom_commands_installed && ask_yes_no "Install Custom Commands (/gemini, /worktree-*, /mermaid)?"; then
        install_custom_commands
    elif is_custom_commands_installed; then
        install_custom_commands  # Just updates enabled.yaml
    fi
    
    # Clean up enabled.yaml to fix any corruption
    rebuild_enabled_yaml
    print_status "Extensions configuration cleaned up"
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
    install_worktree_scripts
    install_selected_extensions

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

    # Handle alias migrations
    handle_alias_migrations

    # Install tmux aliases
    install_tmux_aliases

    # Clean up deprecated aliases
    cleanup_deprecated_aliases

    # Setup tmux configuration
    setup_tmux_config

    # Show completion message
    show_completion_message
}

# Run main function
main "$@" 