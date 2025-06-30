# Worktree Start

Create and set up git worktrees for focused development. Always branch from main, never merge locally.

## Working with Worktrees in Claude Code

After creating a worktree, you have two options to work with it in Claude Code:

### Option 1: Add Worktree to Current Session
```bash
# Add the worktree directory to current Claude session
/add-dir ../feature-branch-name
```
This keeps your current session and adds the worktree as an additional working directory.

### Option 2: Restart Claude from Worktree
```bash
# Exit Claude and restart from the worktree directory
exit
cd ../feature-branch-name
claude
```
This starts a fresh Claude session with the worktree as the primary working directory.

## Prerequisites

```bash
# Check if worktree scripts are installed
git wtclone --help 2>/dev/null && echo "✅ Installed" || echo "❌ Need install"
```

If not installed:
```bash
bash <(curl -s https://raw.githubusercontent.com/tomups/worktrees-scripts/main/install.sh)
```

## Quick Start

```bash
# 1. Navigate to project root
cd /path/to/your-project

# 2. Create worktree from main
git wtadd feature-name main
cd feature-name

# 3. Make changes and commit
# ... work ...
git add . && git commit -m "Implement feature"

# 4. Push and create PR
git push -u origin feature-name
gh pr create --title "Feature title"
```

## Issue Implementation

```bash
# 1. Review issue
gh issue view 123

# 2. Create worktree
git wtadd feature-ui-issue-123 main
cd feature-ui-issue-123

# 3. Implement and commit
git add . && git commit -m "Implement feature - closes #123"

# 4. Push and create PR
git push -u origin feature-ui-issue-123
gh pr create --title "Implement UI feature (#123)"
```

## Setup Notes

The `git wtadd` command automatically:
- Creates new branch from main
- Copies `.env`, `node_modules`, etc.
- Uses Copy-on-Write on macOS

Manual setup if needed:
```bash
npm install && npm run build  # Node.js
pip install -r requirements.txt  # Python
cargo build  # Rust
go mod download && go build  # Go
```

## Troubleshooting

**Permission errors:**
```bash
chmod +x ~/.local/bin/wt*.sh
```

**Files not copying:**
```bash
ls -la .env*
git check-ignore .env
```

**Branch exists:**
```bash
git worktree list
git wtadd new-branch-name main
```

## Best Practices

1. Always branch from main: `git wtadd <branch> main`
2. Never merge locally - use PRs only
3. Use descriptive branch names
4. Include issue numbers in commits
5. Test before creating PR

