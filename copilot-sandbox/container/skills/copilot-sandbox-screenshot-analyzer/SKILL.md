---
name: copilot-sandbox-screenshot-analyzer
description: Analyze screenshots from ~/Screenshots/ mounted read-only in the container. Use when user mentions screenshots, asks to see images, or references visual errors. Extracts text, identifies UI context (GitHub PR comments, VS Code errors, terminal output), and enables action based on visual content.
---

# Screenshot Analyzer

This skill enables analysis of screenshots stored in `~/Screenshots/`, which is mounted as a read-only volume in the Copilot Sandbox container.

## When to use this skill

- User says "read the screenshot", "check the image", "see error-pr.jpg"
- User mentions visual context without providing text details
- Need to analyze PR review comments shown in screenshots
- CI/CD errors captured in images
- Build failures, test results, or IDE warnings in screenshots

## How it works

### 1. List available screenshots

```bash
ls -lt ~/Screenshots/ | head -10
```

Shows the 10 most recent screenshots, ordered by modification time.

### 2. View a specific screenshot

```bash
view ~/Screenshots/filename.jpg
```

The `view` tool can analyze image content and extract:
- Visible text (error messages, code snippets, comments)
- UI context (GitHub, VS Code, terminal, browser)
- Relevant visual elements

### 3. Find screenshots by pattern

```bash
# Search by name
ls ~/Screenshots/ | grep -i "error"

# Get most recent
ls -t ~/Screenshots/ | head -1
```

## Common workflows

### Responding to PR review comments

1. User shares screenshot of GitHub PR comment
2. List screenshots to find the relevant file
3. View the screenshot to see exact comment, line number, file
4. Make the suggested fix
5. Reply to the inline comment thread with fix confirmation

Example:
```bash
# Find the screenshot
ls -lt ~/Screenshots/ | head -5

# Analyze it
view ~/Screenshots/pr-comment.jpg

# Fix the issue identified
sed -i 's/typo/correct/' file.txt
git add file.txt && git commit -m "fix: Correct typo from review"
git push

# Reply to the review comment
gh api -X POST /repos/owner/repo/pulls/2/comments/12345/replies \
  -f body='Fixed! Commit: abc123'
```

### Analyzing CI/CD errors

1. User captures pipeline failure
2. View screenshot to identify error type
3. Check logs or configuration based on error
4. Apply fix and verify

### Debugging build failures

1. Screenshot shows compilation error or missing dependency
2. Extract error message from image
3. Install missing package or fix syntax
4. Rebuild and verify

## Limitations

- Directory is **read-only** - cannot delete or modify files from container
- Supported formats: JPG, PNG, GIF (common image types)
- Analysis quality depends on image resolution and clarity
- Cannot create or edit images, only read them

## Best practices

1. **Always list first**: Use `ls -lt ~/Screenshots/` to see what's available
2. **Confirm with user**: Ask which screenshot to analyze if multiple exist
3. **Describe what you see**: Summarize the screenshot content before taking action
4. **Suggest cleanup**: After using, remind user to delete unnecessary screenshots (from host)

## Integration with other workflows

This skill works particularly well with:
- **git-commit-specialist**: Respond to visual PR feedback
- **code-security-reviewer**: Analyze security scan screenshots
- **feat-implementation**: Reference mockups or design specs
- Any workflow requiring visual context understanding
