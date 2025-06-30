# Parallel Worktree Development Workflow

A comprehensive workflow for setting up multiple parallel development environments using git worktrees with the tomups worktree scripts. This workflow enforces PR-only merges and maintains clean branching from main.

## Prerequisites

Check if the worktree scripts are installed:

```bash
# Check if worktree commands are available
git wtclone --help 2>/dev/null && echo "✅ Worktree scripts installed" || echo "❌ Need to install worktree scripts"
```

If not installed, run:

```bash
bash <(curl -s https://raw.githubusercontent.com/tomups/worktrees-scripts/main/install.sh)
```

## Initial Repository Setup

For new projects, clone as a bare repository with worktree support:

```bash
git wtclone <repository-url> <project-name>
cd <project-name>
```

This creates a bare repository structure optimized for worktrees.

## Variables

- **FEATURE_NAME**: {feature or branch identifier}
- **PROJECT_TYPE**: {node, python, rust, go} - detected automatically

## Parallel Worktree Creation

### Step 1: Navigate to Project Root

```bash
# Ensure you're in the project root (where .bare directory exists)
# This is where wtclone was run initially
cd /path/to/your-project
```

### Step 2: Create Parallel Worktrees

> Always branch from main to ensure clean parallel development
> Execute these commands in parallel for maximum efficiency
> The tomups scripts automatically handle .env copying and setup
> Worktrees will be created as siblings to your main branch directory

**Create first development worktree:**

```bash
git wtadd ${FEATURE_NAME}-1 main
```

**Create second development worktree:**

```bash
git wtadd ${FEATURE_NAME}-2 main
```

**Create third development worktree:**

```bash
git wtadd ${FEATURE_NAME}-3 main
```

### Step 3: Post-Creation Setup

The `git wtadd` command automatically:

- Creates the new branch
- Sets up the worktree directory
- Copies untracked files including `.env`, `.env.local`, `node_modules`, etc.
- Uses Copy-on-Write on macOS/FreeBSD for efficiency

**Manual setup for each worktree (if needed):**

```bash
# Navigate to each worktree and run project-specific setup
cd ${FEATURE_NAME}-1

# Node.js projects
npm install && npm run build

# Python projects  
pip install -r requirements.txt && python setup.py build

# Rust projects
cargo build

# Go projects
go mod download && go build
```

## Advanced Parallel Setup Script

Create a script to automate the entire parallel setup:

```bash
#!/bin/bash
# parallel-setup.sh

FEATURE_NAME="$1"
if [ -z "$FEATURE_NAME" ]; then
    echo "Usage: $0 <feature-name>"
    exit 1
fi

echo "Creating parallel worktrees for feature: $FEATURE_NAME"

# Function to setup individual worktree
setup_worktree() {
    local suffix="$1"
    local branch_name="${FEATURE_NAME}-${suffix}"
    local worktree_path="${branch_name}"
    
    echo "Setting up worktree: $branch_name"
    
    # Create worktree from main (tomups script handles .env copying)
    git wtadd "$worktree_path" main
    
    # Navigate and setup dependencies
    cd "$worktree_path"
    
    # Auto-detect project type and setup
    if [ -f "package.json" ]; then
        # Node.js project
        if command -v pnpm >/dev/null 2>&1; then
            pnpm install
        elif command -v yarn >/dev/null 2>&1; then
            yarn install
        else
            npm install
        fi
        
        # Run build if script exists
        if npm run build --silent 2>/dev/null; then
            echo "Build completed for $branch_name"
        fi
        
    elif [ -f "requirements.txt" ]; then
        # Python project
        pip install -r requirements.txt
        if [ -f "setup.py" ]; then
            python setup.py build
        fi
        
    elif [ -f "Cargo.toml" ]; then
        # Rust project
        cargo build
        
    elif [ -f "go.mod" ]; then
        # Go project
        go mod download
        go build
    fi
    
    cd - >/dev/null
    echo "Completed setup for $branch_name"
}

# Run setups in parallel
setup_worktree "1" &
setup_worktree "2" &  
setup_worktree "3" &

# Wait for all background jobs to complete
wait

echo "✅ All worktrees created and configured!"
echo "Available worktrees:"
echo "  • ${FEATURE_NAME}-1"
echo "  • ${FEATURE_NAME}-2" 
echo "  • ${FEATURE_NAME}-3"
```

## Development Workflow Patterns

### Pattern 1: Feature Experimentation

- **${FEATURE_NAME}-1**: Original approach
- **${FEATURE_NAME}-2**: Alternative implementation
- **${FEATURE_NAME}-3**: Performance-optimized version

### Pattern 2: Testing Strategy

- **${FEATURE_NAME}-1**: Development with new dependencies
- **${FEATURE_NAME}-2**: Stable version for comparison
- **${FEATURE_NAME}-3**: Integration testing environment

### Pattern 3: Code Review Workflow

- **${FEATURE_NAME}-1**: Author's implementation
- **${FEATURE_NAME}-2**: Reviewer's suggestions
- **${FEATURE_NAME}-3**: Final merged approach

## Environment Management

### Automatic File Copying

The tomups `wtadd` script automatically copies:

- `.env` files
- `.env.local` files
- `node_modules` (using Copy-on-Write when possible)
- Other untracked development files

### Custom Environment Variables

Create worktree-specific configurations:

```bash
# In ${FEATURE_NAME}-1/.env.local
API_ENDPOINT=http://localhost:3001
DEBUG_MODE=true
INSTANCE_ID=dev-1

# In ${FEATURE_NAME}-2/.env.local  
API_ENDPOINT=http://localhost:3002
DEBUG_MODE=true
INSTANCE_ID=dev-2

# In ${FEATURE_NAME}-3/.env.local
API_ENDPOINT=http://localhost:3003
DEBUG_MODE=false
INSTANCE_ID=prod-test
```

## Use Cases

- **Feature development**: Test different approaches in parallel
- **Dependency testing**: Compare different package versions
- **Performance optimization**: Benchmark multiple strategies
- **Bug reproduction**: Isolate issues in clean environments
- **Code review**: Create review-specific environments
- **A/B testing**: Compare user experience approaches
- **Refactoring**: Maintain working version during major changes

## Verification and Testing

After setup, verify each worktree:

```bash
# Check git status in each worktree
for dir in ${FEATURE_NAME}-*; do
    echo "=== $dir ==="
    cd "$dir"
    git status --short
    git branch
    cd - >/dev/null
done

# Test build status
for dir in ${FEATURE_NAME}-*; do
    echo "Testing $dir..."
    cd "$dir"
    # Run project-specific test command
    npm test 2>/dev/null || python -m pytest 2>/dev/null || cargo test 2>/dev/null || go test ./... 2>/dev/null || echo "No tests found"
    cd - >/dev/null
done
```

## Cleanup and Merge

### Option 1: Using tomups scripts (recommended)

```bash
# Remove specific worktrees (this also removes the associated branches)
git wtremove ${FEATURE_NAME}-1
git wtremove ${FEATURE_NAME}-2  
git wtremove ${FEATURE_NAME}-3
```

### Option 2: Manual cleanup

```bash
# Remove worktrees and branches
git worktree remove ${FEATURE_NAME}-1
git worktree remove ${FEATURE_NAME}-2
git worktree remove ${FEATURE_NAME}-3

# Delete branches (if no longer needed)
git branch -d ${FEATURE_NAME}-1 ${FEATURE_NAME}-2 ${FEATURE_NAME}-3
```

### Merge Strategy (PR-Only)

```bash
# NO LOCAL MERGING - All merges must go through Pull Requests

# Example: Version 2 had the best approach
cd ${FEATURE_NAME}-2
git add . && git commit -m "Implement best approach for ${FEATURE_NAME}"
git push -u origin ${FEATURE_NAME}-2

# Create PR for the winning approach
gh pr create --title "Implement ${FEATURE_NAME} (Best approach from parallel development)" \
  --body "$(cat <<EOF
## Summary
After parallel development and comparison, this approach was selected as the best solution.

## Parallel Development Results
- **${FEATURE_NAME}-1**: [Brief description of approach 1]
- **${FEATURE_NAME}-2**: ✅ **Selected approach** - [Why this was chosen]
- **${FEATURE_NAME}-3**: [Brief description of approach 3]

## Why This Approach
- [Reason 1: e.g., Better performance]
- [Reason 2: e.g., Cleaner code structure]
- [Reason 3: e.g., Better maintainability]

## Testing
- [ ] All approaches tested and compared
- [ ] Selected approach thoroughly tested
- [ ] Documentation updated

Closes #[issue-number]
EOF
)"

# After PR is merged remotely, clean up all worktrees
git checkout main
git pull origin main
git wtremove ${FEATURE_NAME}-1
git wtremove ${FEATURE_NAME}-2
git wtremove ${FEATURE_NAME}-3
```

## Best Practices

1. **Always branch from main**: Use `git wtadd <branch> main` for clean parallel development
2. **No local merging**: All merges must go through Pull Requests for code review
3. **Naming Convention**: Use descriptive suffixes (e.g., `feature-ui-1`, `feature-api-2`, `feature-perf-3`)
4. **Document approaches**: Keep clear notes on what each worktree is testing
5. **Resource management**: Monitor disk space when using multiple worktrees
6. **Environment isolation**: Use instance-specific configurations for each worktree
7. **Compare systematically**: Test all approaches thoroughly before selecting winner
8. **Regular cleanup**: Remove all worktrees after PR merge to prevent clutter
9. **Pull latest main**: Always `git pull origin main` before creating new parallel worktrees

## Troubleshooting

### Common Issues

**Issue**: Permission errors during setup

```bash
# Solution: Ensure proper permissions
chmod +x ~/.local/bin/wt*.sh
```

**Issue**: .env files not copying

```bash
# Solution: Check if files exist and are not in .gitignore
ls -la .env*
git check-ignore .env
```

**Issue**: Build failures in worktrees

```bash
# Solution: Check dependencies and PATH
cd ${FEATURE_NAME}-1
which node npm  # or relevant tools
env | grep PATH
```

## References

- [Tomups Worktrees Documentation](https://www.tomups.com/worktrees)
- [Git Worktree Official Docs](https://git-scm.com/docs/git-worktree)
- [Parallel Development Best Practices](https://github.com/tomups/worktrees-scripts)