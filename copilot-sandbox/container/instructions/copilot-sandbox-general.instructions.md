# 🐳 Copilot Sandbox Environment Context

**IMPORTANT**: You are running inside a Docker container - the Copilot Sandbox.

```
╭────────────────────────────────────────────────────────╮
│  🐳 Copilot Sandbox - Isolated Development Environment │
│                                                        │
│  • Path mirroring: paths match host exactly            │
│  • Read-only: ~/.ssh, ~/.config/gh, ~/Screenshots      │
│  • Writable cache: /opt/copilot-sandbox/* (persistent) │
│  • Pre-installed: git, gh, docker, node, python, java  │
╰────────────────────────────────────────────────────────╯
```

## You are running inside a Docker container

This is the **Copilot Sandbox**, a Docker-based isolated environment for running GitHub Copilot CLI. Understanding this
context is crucial for effective operation.

### Container Facts

- **Image**: `copilot-sandbox:latest` (based on `node:20-slim`)
- **User**: Running as host user (UID/GID mirrored from host)
- **Architecture**: Linux amd64 (even if host is macOS/ARM)
- **Isolation**: You have your own filesystem, but some directories are shared with the host

## Path Mirroring

The host's home directory is mounted at the **exact same path** inside the container:

```
Host:      /Users/william/project
Container: /Users/william/project  (identical path!)
```

**This means:**

- `pwd` returns the same path as on the host
- Files you edit persist on the host automatically
- `.git` directory is shared (same repository)
- Your changes are immediately visible to the host

## Mount Points

### Read-Only Mounts

These directories cannot be modified from inside the container:

| Path             | Purpose                  | Workaround                                        |
|------------------|--------------------------|---------------------------------------------------|
| `~/.ssh/`        | SSH keys                 | Copied to `/tmp/.ssh-copilot-sandbox/` (writable) |
| `~/.config/gh/`  | GitHub CLI config        | Read-only, but `gh auth token` works              |
| `~/Screenshots/` | Screenshots for analysis | View only, user must delete from host             |

**Important**: SSH works automatically via `GIT_SSH_COMMAND` configured in `user-entrypoint.sh`.

### Writable Persistent Cache

This directory survives container restarts and is shared across sessions:

```
Host:      ~/.copilot-sandbox/
Container: /opt/copilot-sandbox/
```

**Contains:**

- `volta/` - Node.js, npm, yarn binaries (Linux)
- `sdkman/` - Java, Gradle, Maven
- `npm/` - npm global cache
- `uv/` - Python uv/uvx cache
- `config/` - XDG cache and data directories

**Always use these paths** instead of defaults to ensure persistence.

## Pre-configured Environment

### Environment Variables

```bash
VOLTA_HOME=/opt/copilot-sandbox/volta
SDKMAN_DIR=/opt/copilot-sandbox/sdkman
npm_config_cache=/opt/copilot-sandbox/npm
UV_CACHE_DIR=/opt/copilot-sandbox/uv
XDG_CACHE_HOME=/opt/copilot-sandbox/config/cache
XDG_DATA_HOME=/opt/copilot-sandbox/config/data
GITHUB_TOKEN=(from host gh auth token)
COPILOT_CUSTOM_INSTRUCTIONS_DIRS=$HOME/.copilot/instructions
```

### Available Tools

**Core**: git, curl, wget, jq, ssh, bash, zsh, gh (GitHub CLI)

**Languages**:

- Node.js 20 (via Volta: `node`, `npm`, `npx`, `yarn`)
- Python 3 (with `python3`, `pip3`, `uv`, `uvx`)
- Java ecosystem (via SDKMAN: `java`, `gradle`, `maven`)

**Development**: Docker CLI (talks to host daemon), GitHub Copilot CLI

## Common Patterns

### Installing packages

```bash
# Node.js (via Volta - automatically uses correct cache)
npm install -g typescript

# Python (via uv - uses UV_CACHE_DIR)
uvx ruff

# Java (via SDKMAN)
sdk install gradle
```

### Using Docker

When you run `docker` commands:

- They execute against the **host Docker daemon**
- Containers you create are **siblings**, not children
- Use host paths for volumes: `-v ~/project:/app`
- Network is shared with host

### Working with Git

```bash
# SSH authentication works automatically
git push origin main

# Git signing is pre-configured if enabled on host
git commit -S -m "Signed commit"
```

### Reading Screenshots

The `~/Screenshots/` directory is mounted read-only:

```bash
# ✅ View/analyze
ls ~/Screenshots/
view ~/Screenshots/error.jpg

# ❌ Cannot delete
rm ~/Screenshots/old.jpg  # Permission denied
```

Tell the user to delete files from the host if needed.

## Architecture: Two-Phase Execution

The sandbox uses a two-phase startup:

**Phase 1 - Init (root, non-interactive)**

- Runs `entrypoint.sh` as root
- Integrates CA certificates
- Creates mirrored user (UID/GID from host)
- Seeds tool caches (Volta, SDKMAN)
- Sets permissions on Docker socket
- Exits after setup

**Phase 2 - Run (host user, interactive)**

- Runs `user-entrypoint.sh` with `--user UID:GID`
- Registers user in `/etc/passwd`
- Configures SSH, Git signing, environment
- Executes `copilot` with direct TTY access

You're in **Phase 2** - setup is complete, you have user permissions and all tools ready.

## Troubleshooting

### Permission denied on read-only mounts

```bash
# Check if path is read-only
mount | grep -E "(ssh|Screenshots|config/gh)"
```

If yes, that's expected. Use workarounds documented above.

### Tool not found

```bash
# Verify tool installation
which node npm python3 docker gh

# Check PATH
echo $PATH | tr ':' '\n'
```

### Cache not persisting

Ensure you're using `/opt/copilot-sandbox/` paths, not home directory defaults.

## Skills Available

The following skills provide additional context and capabilities:

- **screenshot-analyzer**: Analyze images from `~/Screenshots/`
- **sandbox-context**: Detailed environment information (this file references it)

## Summary

**Key Points:**

- You're in a Linux container (even on macOS host)
- Paths mirror the host for transparency
- Some mounts are read-only (SSH, Screenshots)
- Use persistent caches in `/opt/copilot-sandbox/`
- Docker commands talk to host daemon
- All development tools are pre-configured

When in doubt about the environment, consult this file or the `sandbox-context` skill.
