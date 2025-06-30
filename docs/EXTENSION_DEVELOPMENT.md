# Extension Development Guide

## Overview

This guide covers how to develop and integrate new command extensions with the Claude Workspace Tools system.

## Extension Structure

### Basic Extension Layout

```
your-extension/
├── README.md                 # Extension documentation
├── install.sh               # Installation script (optional)
├── commands/                 # Command definitions
│   ├── your-command1.md
│   ├── your-command2.md
│   └── shared/              # Shared resources (optional)
│       └── patterns.yml
└── config/                  # Extension configuration (optional)
    └── settings.yaml
```

### Command File Format

Claude Code commands use Markdown format with special syntax:

```markdown
# Command Name

Brief description of what the command does.

## Usage

```bash
/your-command [arguments] [--flags]
```

## Arguments

- `argument1` - Description of argument
- `--flag` - Description of flag

## Examples

```bash
/your-command example-input --verbose
```

## Implementation

The actual command implementation using Claude Code syntax...
```

## Development Process

### 1. Planning Your Extension

Before development, consider:

- **Purpose**: What specific problem does your extension solve?
- **Commands**: What commands will you provide?
- **Dependencies**: What external tools or APIs are required?
- **Integration**: How will it work with existing extensions?

### 2. Creating Command Files

#### Basic Command Template

```markdown
# Your Command

Description of what the command does and when to use it.

## Syntax

/your-command [required-arg] [optional-arg] [--flag]

## Arguments

- `required-arg` - Description of required argument
- `optional-arg` - Description of optional argument (default: value)
- `--flag` - Description of flag behavior

## Examples

### Basic Usage
/your-command input-value

### Advanced Usage  
/your-command input-value optional-value --flag

## Implementation

[Command implementation logic here]

@include shared/your-patterns.yml#Pattern_Name (if using shared patterns)
```

#### Advanced Features

**Using Shared Patterns:**
```markdown
@include shared/validation.yml#Input_Validation
@include shared/error-handling.yml#Standard_Error_Response
```

**Conditional Logic:**
```markdown
## Conditional Execution

If $ARGUMENTS contains "--verbose":
  [verbose implementation]
Else:
  [standard implementation]
```

**Integration with Other Tools:**
```markdown
## Tool Integration

Execute: `your-external-tool $ARGUMENTS`
Parse output and provide structured response
```

### 3. Creating Installation Script

#### Basic Installation Script

```bash
#!/bin/bash

set -e

EXTENSION_NAME="your-extension"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"

# Create directories
mkdir -p "$COMMANDS_DIR"

# Copy command files
cp commands/*.md "$COMMANDS_DIR/"

# Copy shared resources (if any)
if [ -d "commands/shared" ]; then
    mkdir -p "$CLAUDE_DIR/shared"
    cp -r commands/shared/* "$CLAUDE_DIR/shared/"
fi

echo "✅ $EXTENSION_NAME installed successfully!"
```

#### Advanced Installation Script

```bash
#!/bin/bash

set -e

EXTENSION_NAME="your-extension"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SHARED_DIR="$CLAUDE_DIR/shared"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Check for required tools
    for tool in your-required-tool; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            print_error "$tool is required but not installed"
            exit 1
        fi
    done
    
    print_success "All dependencies satisfied"
}

# Install commands
install_commands() {
    print_status "Installing commands..."
    
    mkdir -p "$COMMANDS_DIR"
    mkdir -p "$SHARED_DIR"
    
    # Copy command files
    for cmd in commands/*.md; do
        if [ -f "$cmd" ]; then
            cp "$cmd" "$COMMANDS_DIR/"
        fi
    done
    
    # Copy shared resources
    if [ -d "commands/shared" ]; then
        cp -r commands/shared/* "$SHARED_DIR/"
    fi
    
    print_success "Commands installed"
}

# Configure extension
configure_extension() {
    print_status "Configuring extension..."
    
    # Add any extension-specific configuration
    # This might include setting up API keys, creating config files, etc.
    
    print_success "Configuration complete"
}

# Main installation
main() {
    print_status "Installing $EXTENSION_NAME..."
    
    check_dependencies
    install_commands
    configure_extension
    
    print_success "$EXTENSION_NAME installed successfully!"
    print_status "Available commands:"
    for cmd in commands/*.md; do
        if [ -f "$cmd" ]; then
            cmd_name=$(basename "$cmd" .md)
            echo "  /$cmd_name"
        fi
    done
}

main "$@"
```

### 4. Integration with Setup Script

To integrate your extension with the main setup script:

#### 1. Add to extensions.yaml

```yaml
extensions:
  your-extension:
    repo: "https://github.com/your-username/your-extension.git"
    description: "Brief description of your extension"
    installer: "install.sh"
    commands: 3
    categories: ["category1", "category2"]
```

#### 2. Create Detection Function

```bash
is_your_extension_installed() {
    # Check for extension-specific files that indicate installation
    [ -f "$HOME/.claude/commands/your-command1.md" ] && \
    [ -f "$HOME/.claude/commands/your-command2.md" ] && \
    [ -f "$HOME/.claude/your-extension-marker" ]  # Optional marker file
}
```

#### 3. Create Installation Function

```bash
install_your_extension() {
    if is_your_extension_installed; then
        print_success "Your Extension is already installed"
        add_to_enabled_yaml "your-extension"
        return 0
    fi
    
    print_status "Installing Your Extension..."
    
    local extension_dir="extensions/your-extension"
    
    if [ -d "$extension_dir" ]; then
        cd "$extension_dir"
        if [ -f "install.sh" ]; then
            ./install.sh
            print_success "Your Extension installed successfully"
            cd ../..
            add_to_enabled_yaml "your-extension"
        else
            print_error "Installation script not found"
        fi
    else
        print_error "Extension directory not found"
    fi
}
```

#### 4. Add to Installation Flow

```bash
install_selected_extensions() {
    # ... existing code ...
    
    if ! is_your_extension_installed && ask_yes_no "Install Your Extension?"; then
        install_your_extension
    elif is_your_extension_installed; then
        install_your_extension  # Updates enabled.yaml
    fi
    
    # ... existing code ...
}
```

## Best Practices

### Command Design

1. **Clear Naming**: Use descriptive command names that indicate purpose
2. **Consistent Arguments**: Follow consistent patterns for arguments and flags
3. **Help Documentation**: Always include usage examples and clear descriptions
4. **Error Handling**: Provide meaningful error messages and recovery suggestions

### Code Organization

1. **Modular Design**: Break complex functionality into smaller, focused commands
2. **Shared Resources**: Use shared YAML files for common patterns and configurations
3. **Documentation**: Maintain clear README and inline documentation
4. **Version Control**: Use semantic versioning for extension releases

### Integration Guidelines

1. **Non-Intrusive**: Don't modify existing commands or configurations
2. **Dependency Management**: Clearly document and check for dependencies
3. **Configuration Isolation**: Use extension-specific configuration files
4. **Backward Compatibility**: Maintain compatibility with existing installations

### Testing

1. **Installation Testing**: Test installation on clean systems
2. **Command Testing**: Verify all commands work as expected
3. **Integration Testing**: Test interaction with other extensions
4. **Error Case Testing**: Test error conditions and recovery

## Advanced Features

### Shared Pattern Libraries

Create reusable patterns in `commands/shared/`:

```yaml
# patterns.yml
Your_Pattern_Name:
  validation: |
    Validate input arguments:
    - Check required parameters
    - Validate format and constraints
    - Return error if validation fails
  
  execution: |
    Execute main command logic:
    - Process validated inputs
    - Perform core functionality
    - Generate structured output
  
  error_handling: |
    Handle errors gracefully:
    - Provide clear error messages
    - Suggest corrective actions
    - Log errors for debugging
```

### Dynamic Configuration

Support runtime configuration through environment variables:

```markdown
## Configuration

This command supports the following environment variables:

- `YOUR_EXTENSION_API_KEY` - API key for external service
- `YOUR_EXTENSION_TIMEOUT` - Request timeout in seconds (default: 30)
- `YOUR_EXTENSION_VERBOSE` - Enable verbose output (default: false)

## Implementation

Check environment variables:
- If $YOUR_EXTENSION_API_KEY is not set, prompt user to configure
- Use $YOUR_EXTENSION_TIMEOUT for request timeout
- Enable verbose output if $YOUR_EXTENSION_VERBOSE is true
```

### Multi-Command Workflows

Create commands that work together:

```markdown
# Command 1: Initialize

/your-init [project-name]
Creates initial configuration and state

# Command 2: Process

/your-process [input]
Processes input using configuration from your-init

# Command 3: Finalize

/your-finalize
Completes workflow and cleans up state
```

## Distribution

### Repository Setup

1. Create GitHub repository with clear README
2. Use releases for version management
3. Include installation instructions
4. Provide usage examples

### Documentation

1. **README.md**: Overview, installation, usage
2. **COMMANDS.md**: Detailed command reference
3. **CHANGELOG.md**: Version history and changes
4. **CONTRIBUTING.md**: Guidelines for contributors

### Community Integration

1. Submit to extension registry (when available)
2. Share in community forums
3. Contribute back improvements to core system
4. Collaborate with other extension developers

## Example Extension

See `extensions/custom-commands/` for a complete example of:
- Multiple related commands
- Installation without external script
- Integration with existing workflows
- Clear documentation and usage patterns

This example demonstrates how to create workflow-specific commands that enhance the overall development experience.