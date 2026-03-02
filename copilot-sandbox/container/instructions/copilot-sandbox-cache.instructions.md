---
applyTo: "**/*cache*,**/*node_modules*,**/package*.json,**/requirements.txt,**/pom.xml,**/build.gradle*"
---

# Cache and Package Management in Copilot Sandbox

When installing tools, packages, or managing caches:

## Use persistent cache directories

The sandbox provides persistent caches in `/opt/copilot-sandbox/` that survive container restarts.

### Node.js / npm

**Automatic** - Volta and npm are pre-configured to use the correct caches:

```bash
# ✅ Automatically uses /opt/copilot-sandbox/volta and /opt/copilot-sandbox/npm
npm install -g typescript
npx create-react-app my-app
```

Environment variables already set:

```bash
VOLTA_HOME=/opt/copilot-sandbox/volta
npm_config_cache=/opt/copilot-sandbox/npm
```

### Python / pip / uv

**Automatic** - uv/uvx use the configured cache:

```bash
# ✅ Uses UV_CACHE_DIR=/opt/copilot-sandbox/uv
uvx ruff check .
uv pip install requests
```

For pip, use `--cache-dir` if needed:

```bash
pip3 install --cache-dir=/opt/copilot-sandbox/uv/pip requests
```

### Java / Maven / Gradle

**Automatic** - SDKMAN manages installations in the persistent cache:

```bash
# ✅ Installs to SDKMAN_DIR=/opt/copilot-sandbox/sdkman
sdk install gradle 8.5
sdk use java 17.0.9-tem
```

### XDG directories

Applications using XDG Base Directory Specification automatically use:

```bash
XDG_CACHE_HOME=/opt/copilot-sandbox/config/cache
XDG_DATA_HOME=/opt/copilot-sandbox/config/data
```

## What to AVOID

```bash
# ❌ Don't install to home directory
pip3 install --user package  # Will be lost on restart

# ❌ Don't use default caches in /root or /tmp
npm config set cache /root/.npm  # Wrong location

# ❌ Don't install binaries to /usr/local
sudo apt install tool  # No sudo, and won't persist
```

## Checking cache usage

```bash
# Verify npm cache location
npm config get cache
# Should show: /opt/copilot-sandbox/npm

# Check Volta home
echo $VOLTA_HOME
# Should show: /opt/copilot-sandbox/volta

# List installed Node.js versions
volta list

# Check Python uv cache
echo $UV_CACHE_DIR
# Should show: /opt/copilot-sandbox/uv

# See SDKMAN installations
sdk list java
```

## Why this matters

- **Persistence**: Tools installed persist across container restarts
- **Performance**: Downloaded packages are cached and reused
- **Consistency**: Same tools available in every session
- **Space efficiency**: No re-downloading on each startup

## Architecture note

The host directory `~/.copilot-sandbox/` is mounted to `/opt/copilot-sandbox/` in the container. This avoids binary
incompatibility (macOS ARM binaries won't work in Linux amd64 container).

## Summary

- Node.js, Python, Java tools use persistent caches **automatically**
- No special action needed - environment is pre-configured
- Check environment variables to verify correct paths
- Never install to `~`, `/root`, or `/usr/local`
