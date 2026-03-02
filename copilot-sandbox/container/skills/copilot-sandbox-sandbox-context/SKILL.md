---
name: copilot-sandbox-sandbox-context
description: Understanding the Copilot Sandbox container environment - paths, mounts, caches, and architecture. Use when troubleshooting path issues, permission errors, or environment confusion. Explains where files live, what's read-only vs writable, and how tools are configured.
---

# Sandbox Context

This skill provides complete understanding of the Copilot Sandbox Docker container environment in which Copilot is currently running.

## When to use this skill

- Path-related errors or confusion about file locations
- Permission denied errors (understanding read-only vs writable)
- Cache or tool configuration issues
- Need to explain why certain operations fail
- User asks "where am I?", "what environment is this?", "why can't I write here?"

## Container architecture

### Two-phase execution model

The sandbox uses two separate `docker run` commands:

**Phase 1 - Init (root, non-interactive)**
- Runs `entrypoint.sh` as root
- Integrates CA certificates
- Creates user matching host UID/GID
- Creates `/opt/copilot-sandbox/volta/` directory and sets ownership
- Seeds SDKMAN cache from image (if not already present)
- Sets ownership on all cache directories
- Adjusts Docker socket permissions

**Phase 2 - Run (host user, interactive)**
- Runs `user-entrypoint.sh` with `--user UID:GID`
- Registers user in `/etc/passwd` (required by git, ssh)
- Configures environment variables (PATH, caches, XDG dirs)
- Creates writable SSH config from read-only mounted keys
- Applies git commit signing from env vars
- **Installs Volta + Node.js 24 + Copilot CLI on first run** (skips if already in cache)
- `exec copilot` - Copilot process gets TTY directly

## Path mirroring

**Critical**: The host home directory is mounted at the **same path** inside the container, NOT at `/root`.

```
Host:      /Users/william.correa/Work/project
Container: /Users/william.correa/Work/project  (same!)
```

This transparency means:
- Absolute paths work the same way in both environments
- Git repositories maintain their paths
- Relative paths behave identically
- Tools that store absolute paths in config work correctly

## Read-only mounts

These directories are mounted as **read-only** from the host:

### `~/.ssh` → `/tmp/.ssh-copilot-sandbox/`
- Original mount is read-only to protect keys
- `user-entrypoint.sh` creates writable copy in `/tmp/.ssh-copilot-sandbox/`
- Git uses this via `GIT_SSH_COMMAND="ssh -F /tmp/.ssh-copilot-sandbox/config"`
- SSH keys, known_hosts, config available but safe

### `~/.config/gh` (GitHub CLI auth)
- GitHub CLI token from `gh auth token` on host
- Passed via `GITHUB_TOKEN` env var
- No need for gh auth inside container

### `~/Screenshots` (screenshot analysis)
- Read-only access to screenshots directory
- Use `view` tool to analyze images
- Cannot delete or modify from container
- Default location: `~/Screenshots` (override with `COPILOT_SCREENSHOTS_DIR`)

## Writable persistent caches

Cache directory: `~/.copilot-sandbox/` (host) → `/opt/copilot-sandbox/` (container)

**Why external to container?**
- Prevents architecture conflicts (macOS ARM vs Linux AMD64)
- Persists across container rebuilds
- Shared between all sandbox instances
- Faster startup (no re-download)

### Cache structure

```
/opt/copilot-sandbox/    (~/.copilot-sandbox/ on host)
├── volta/         # Node.js version manager + Copilot CLI
├── sdkman/        # Java, Kotlin, Gradle, Maven
├── npm/           # npm global cache
├── uv/            # uv/uvx cache (Python packages)
├── config/        # XDG cache and data dirs
└── completions/   # Zsh completions
```

Each cache is configured via environment variables:
- `VOLTA_HOME=/opt/copilot-sandbox/volta`
- `SDKMAN_DIR=/opt/copilot-sandbox/sdkman`
- `npm_config_cache=/opt/copilot-sandbox/npm`
- `UV_CACHE_DIR=/opt/copilot-sandbox/uv`
- `XDG_CACHE_HOME=/opt/copilot-sandbox/config/cache`
- `XDG_DATA_HOME=/opt/copilot-sandbox/config/data`

## Available tools (pre-installed)

Base tools:
- `git`, `curl`, `jq`, `gh` (GitHub CLI)
- `docker` CLI (socket mounted from host)
- `jira` — Jira Cloud CLI (see `copilot-sandbox-jira-cli` skill)
- `http` — HTTP client wrapper around curl (see `copilot-sandbox-http-cli` skill)
- `confluence` — Confluence Cloud CLI (see `copilot-sandbox-confluence-cli` skill)

Language toolchains:
- **Node.js**: Managed by Volta (`.nvmrc` auto-detects version)
- **Python**: System Python 3 + `uv`/`uvx` for fast installs
- **Java/JVM**: SDKMAN with Java, Gradle, Maven, Kotlin

GitHub Copilot:
- `@github/copilot` npm package (you are running right now!)

## Docker socket access

The host Docker socket is mounted at `/var/run/docker.sock`, allowing:
- `docker build`, `docker run` commands
- Building images from Dockerfiles
- Running integration tests in containers

**Important**: Docker commands run on the **host** Docker daemon, not inside the container. Images and containers are visible on the host system.

## Common troubleshooting

### "Permission denied" on ~/.ssh
- **Cause**: Trying to write to read-only mount
- **Solution**: Use `/tmp/.ssh-copilot-sandbox/` for writable operations
- Git is already configured to use this path

### "No user exists for uid X"
- **Cause**: Missing `/etc/passwd` entry (should not happen)
- **Solution**: Check `user-entrypoint.sh` ran successfully

### Cache not persisting
- **Cause**: Tool using wrong cache directory
- **Solution**: Check env vars point to `/opt/copilot-sandbox/`

### Path doesn't exist
- **Cause**: Expecting path at different location
- **Solution**: Remember paths are mirrored, not remapped to /root

### Can't delete screenshots
- **Cause**: ~/Screenshots is read-only mount
- **Solution**: Ask user to delete from host system

## Best practices

1. **Always check environment**: When debugging, remember you're in a container
2. **Use persistent caches**: Tools should use `/opt/copilot-sandbox/` subdirs
3. **Respect read-only mounts**: Don't try to write to ~/.ssh, ~/.config/gh, ~/Screenshots
4. **Leverage path mirroring**: Absolute paths work the same as on host
5. **Use Docker socket carefully**: Remember containers/images appear on host

## Integration with project workflow

This context is **always active** regardless of the project you're working on. The sandbox provides a consistent, reproducible environment with:
- Isolated tool versions
- Persistent caches
- Protected credentials
- Container-in-container capabilities

When working on user projects, remember:
- Project files are at their original paths (mirrored)
- Project `.nvmrc`, `build.gradle`, `requirements.txt` work normally
- Tools auto-detect project configuration
- But tool caches/installations persist in `/opt/copilot-sandbox/`
