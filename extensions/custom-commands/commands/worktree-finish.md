# Worktree Finish

Complete development work and clean up worktrees. All merges via PR only.

## Complete Your Work

```bash
# Final commit and push
git add .
git commit -m "Implement feature - closes #123"
git push -u origin branch-name

# Create PR
gh pr create --title "Feature title" --body "Brief description"
```

## Cleanup After PR Merge

```bash
# After PR is merged remotely
git checkout main
git pull origin main
git wtremove branch-name  # Removes worktree and branch
```

### If Using Claude Code with /add-dir
If you added the worktree using `/add-dir`, you may want to restart Claude from the main directory:
```bash
# Option 1: Continue in current session (worktree files no longer accessible)
# Option 2: Restart Claude from main directory
exit
cd /path/to/main/project
claude
```

## Multiple Worktree Cleanup

```bash
# Clean up all related worktrees
for branch in feature-name-1 feature-name-2 feature-name-3; do
    git wtremove $branch
done
```

## Manual Cleanup Options

```bash
# Keep branch, remove worktree only
git worktree remove branch-name

# Force remove if issues
git worktree remove --force branch-name
git worktree prune
```

## Emergency Cleanup

```bash
# If worktree is corrupted
git worktree remove --force branch-name
rm -rf branch-name  # Remove directory
git worktree prune
git remote prune origin
```

## Verification

```bash
# Check clean state
git status
git worktree list
git branch -vv
```

## Best Practices

1. Always pull main before cleanup
2. Verify PR is merged before removing worktree  
3. Use `git wtremove` (preferred) over manual cleanup
4. Clean up promptly after PR merge
5. Check `git worktree list` after cleanup

## Troubleshooting

**Cannot remove worktree:**
```bash
# Close editors/processes using directory
lsof +D worktree-path
git worktree remove --force branch-name
```

**Branch not merged:**
```bash
git branch --merged main | grep branch-name
git branch -D branch-name  # Force delete if needed
```

**Directory remains:**
```bash
rm -rf worktree-directory
git worktree prune
```