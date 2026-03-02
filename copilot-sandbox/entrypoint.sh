#!/bin/bash
set -e

# Colors for output
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$*" >&2; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; exit 1; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$*" >&2; }

# Configure corporate CA certificate if mounted
if [ -f /usr/local/share/ca-certificates/extra-ca.crt ]; then
  update-ca-certificates
fi

HOST_UID="${HOST_UID:-0}"
HOST_GID="${HOST_GID:-0}"
HOST_USER="${HOST_USER:-root}"
HOST_HOME="${HOST_HOME:-/root}"

# If running as root, no user setup needed
if [ "$HOST_UID" = "0" ]; then
  exit 0
fi

# Create group if it doesn't exist
if ! getent group "$HOST_GID" > /dev/null 2>&1; then
  groupadd -g "$HOST_GID" "$HOST_USER" 2>/dev/null || true
fi

# Create user if it doesn't exist
if ! id -u "$HOST_UID" > /dev/null 2>&1; then
  useradd -u "$HOST_UID" -g "$HOST_GID" -M -d "$HOST_HOME" -s /bin/bash "$HOST_USER" 2>/dev/null || true
fi

# Setup container-local tool directories
COPILOT_SANDBOX_DIR="/opt/copilot-sandbox"

# Ensure base cache dirs exist (volume may be freshly created)
mkdir -p "$COPILOT_SANDBOX_DIR"/{volta,npm,uv,config,completions}

# SDKMAN — seed from image if cache is empty
if [ ! -f "$COPILOT_SANDBOX_DIR/sdkman/bin/sdkman-init.sh" ]; then
  mkdir -p "$COPILOT_SANDBOX_DIR/sdkman"
  if cp -rL /root/.sdkman/. "$COPILOT_SANDBOX_DIR/sdkman/" 2>/dev/null; then
    chown -R "$HOST_UID:$HOST_GID" "$COPILOT_SANDBOX_DIR/sdkman"
  else
    warn "Failed to seed SDKMAN cache from image"
  fi
else
  chown -R "$HOST_UID:$HOST_GID" "$COPILOT_SANDBOX_DIR/sdkman"
fi

# Fix ownership of the entire cache volume so the host user can write
chown "$HOST_UID:$HOST_GID" "$COPILOT_SANDBOX_DIR"
chown -R "$HOST_UID:$HOST_GID" "$COPILOT_SANDBOX_DIR"/{volta,npm,uv} 2>/dev/null || true

# Copilot base directory in host home
COPILOT_BASE_DIR="$HOST_HOME/.copilot"
mkdir -p "$COPILOT_BASE_DIR"

# Copilot Agent Skills — always sync to ~/.copilot/skills/
# Skills are prefixed with 'copilot-sandbox-' to avoid conflicts with user's personal skills
COPILOT_SKILLS_DIR="$COPILOT_BASE_DIR/skills"
mkdir -p "$COPILOT_SKILLS_DIR"

if [ -d "/opt/copilot-sandbox/skills" ]; then
  info "Seeding skills from image..."
  cp -r /opt/copilot-sandbox/skills/* "$COPILOT_SKILLS_DIR/" 2>/dev/null || true
else
  warn "Skills directory not found in image: /opt/copilot-sandbox/skills"
fi

# Copilot Instructions — always sync to ~/.copilot/instructions/
# Instructions are prefixed with 'copilot-sandbox-' to avoid conflicts
COPILOT_INSTRUCTIONS_DIR="$COPILOT_BASE_DIR/instructions"
mkdir -p "$COPILOT_INSTRUCTIONS_DIR"

if [ -d "/opt/copilot-sandbox/instructions" ]; then
  info "Seeding instructions from image..."
  cp -r /opt/copilot-sandbox/instructions/* "$COPILOT_INSTRUCTIONS_DIR/" 2>/dev/null || true
else
  warn "Instructions directory not found in image: /opt/copilot-sandbox/instructions"
fi

# Ensure the entire ~/.copilot tree is owned by the host user
chown -R "$HOST_UID:$HOST_GID" "$COPILOT_BASE_DIR"