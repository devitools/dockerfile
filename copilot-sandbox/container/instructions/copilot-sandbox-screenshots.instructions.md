---
applyTo: "**/Screenshots/**,~/Screenshots/**"
---

# Screenshot Handling in Copilot Sandbox

When working with files in or references to `~/Screenshots/`:

## The directory is READ-ONLY

You **cannot** delete, rename, or modify files in `~/Screenshots/` from inside the container.

### What you CAN do

```bash
# ✅ List files
ls -lt ~/Screenshots/

# ✅ View/analyze images
view ~/Screenshots/error-pr.jpg

# ✅ Grep for specific names
ls ~/Screenshots/ | grep -i "error"

# ✅ Get the most recent
ls -t ~/Screenshots/ | head -1
```

### What you CANNOT do

```bash
# ❌ Delete files
rm ~/Screenshots/old.jpg  # Will fail with "Read-only file system"

# ❌ Move files
mv ~/Screenshots/a.jpg ~/Screenshots/b.jpg  # Will fail

# ❌ Edit files
touch ~/Screenshots/test.jpg  # Will fail
```

## Workflow

1. **List available screenshots**: Always check what's there first
2. **View the relevant one**: Use the `view` tool to analyze content
3. **Take action**: Based on what you see (fix code, reply to comments, etc)
4. **Inform user**: If files should be deleted, tell user to do it from host

## Example: Responding to PR review

```bash
# 1. Find screenshot
ls -lt ~/Screenshots/ | head -5

# 2. Analyze it
view ~/Screenshots/pr-review-comment.jpg

# 3. Make the fix (in the actual codebase, not Screenshots)
sed -i 's/typo/correct/' src/file.js
git commit -m "fix: Correct typo from review"

# 4. Reply to review thread
gh api -X POST /repos/owner/repo/pulls/2/comments/123/replies \
  -f body='Fixed in commit abc123'
```

## Cleanup

If you need screenshots removed, instruct the user:

> "Please delete `~/Screenshots/filename.jpg` from your host system when you're done with it. I cannot delete it from inside the container."

## Related

See the **screenshot-analyzer** skill for detailed workflows on analyzing screenshots.
