# Gemini for Large Codebase Analysis

Use Gemini's massive context window for analyzing large codebases that exceed Claude's limits.

## When to Use Gemini

- ✅ Entire codebase analysis (>100KB)
- ✅ Multi-directory feature verification  
- ✅ Project-wide security audits
- ✅ Architecture understanding
- ❌ Writing new code (use Claude)
- ❌ Interactive debugging (use Claude)

## Basic Syntax

```bash
# Single file
gemini -p "@src/main.py Explain this file's purpose"

# Multiple files  
gemini -p "@package.json @src/index.js Analyze dependencies"

# Directories
gemini -p "@src/ @tests/ Check test coverage"

# Entire project
gemini -p "@./ Project overview"
gemini --all_files -p "Analyze project structure"
```

## Common Analysis Patterns

### Feature Verification

```bash
gemini -p "@src/ @lib/ Has authentication been implemented? Show files and functions"
gemini -p "@src/ Are WebSocket connections handled? Show implementation"
```

### Security Checks

```bash
gemini -p "@src/ @api/ Are SQL injection protections implemented?"
gemini -p "@middleware/ @auth/ Is rate limiting implemented?"
```

### Architecture Analysis

```bash
gemini -p "@src/ What's the overall architecture pattern?"
gemini -p "@./ Summarize project structure and key technologies"
```

### Code Quality

```bash
gemini -p "@src/ @api/ Is proper error handling implemented?"
gemini -p "@tests/ What's the test coverage strategy?"
```

## Integration with Worktree Workflow

```bash
# Before starting work
gemini -p "@./ Overview of this project"
gemini -p "@src/ Has user dashboard been implemented?"

# Start development
git wtadd feature-dashboard main
cd feature-dashboard

# During development  
gemini -p "@src/components/ Show similar UI components for reference"

# Finish
git push -u origin feature-dashboard && gh pr create
```

## Tips

- Paths are relative to current directory
- Be specific in questions for better results
- Save large outputs: `gemini -p "..." > analysis.md`
- Use for understanding, Claude for implementing