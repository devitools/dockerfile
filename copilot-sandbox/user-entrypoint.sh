#!/bin/bash
# Runs as the host user (via --user). No root, no gosu, no su.
# TTY is passed directly from Docker — interactive tools work natively.

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$*" >&2; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$*" >&2; }

# Ensure user exists in /etc/passwd (git, ssh, etc. require it)
if ! whoami >/dev/null 2>&1; then
  echo "${HOST_USER:-copilot-sandbox}:x:$(id -u):$(id -g)::${HOME:-/tmp}:/bin/bash" >> /etc/passwd 2>/dev/null || true
fi

# Environment setup
if [ -S /var/run/docker.sock ]; then
  export DOCKER_HOST=unix:///var/run/docker.sock
fi
export VOLTA_HOME="/opt/copilot-sandbox/volta"
export SDKMAN_DIR="/opt/copilot-sandbox/sdkman"
export npm_config_cache=/opt/copilot-sandbox/npm
export UV_CACHE_DIR=/opt/copilot-sandbox/uv
export XDG_CACHE_HOME="/opt/copilot-sandbox/config/cache"
export XDG_DATA_HOME="/opt/copilot-sandbox/config/data"
export PATH="$VOLTA_HOME/bin:$PATH"

# Copilot customization directories
export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/.copilot/instructions"

# Ensure XDG dirs exist
mkdir -p "$XDG_CACHE_HOME" "$XDG_DATA_HOME" 2>/dev/null || true

# Install Volta if not present
if [ ! -f "$VOLTA_HOME/bin/volta" ]; then
  info "Installing Volta..."
  export VOLTA_HOME="$VOLTA_HOME"
  if ! curl -fsSL https://get.volta.sh | bash -s -- --skip-setup; then
    error "Failed to install Volta (curl/get.volta.sh). Aborting."
    exit 1
  fi
fi

# Install Node and Copilot if not present
if [ ! -f "$VOLTA_HOME/bin/copilot" ]; then
  info "Installing Node.js and Copilot CLI..."
  if ! "$VOLTA_HOME/bin/volta" install node@24; then
    error "Failed to install Node.js via Volta. Aborting."
    exit 1
  fi
  if ! "$VOLTA_HOME/bin/volta" install @github/copilot@latest; then
    error "Failed to install GitHub Copilot CLI via Volta. Aborting."
    exit 1
  fi
fi

# Corporate CA certificate
if [ -f /usr/local/share/ca-certificates/extra-ca.crt ]; then
  export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/extra-ca.crt
  # Combine system CA bundle with corporate cert so git/curl trust both
  _combined_ca="/tmp/combined-ca.crt"
  cat /etc/ssl/certs/ca-certificates.crt /usr/local/share/ca-certificates/extra-ca.crt > "$_combined_ca"
  export GIT_SSL_CAINFO="$_combined_ca"
fi

# SSH config — reconstruct from host keys (init phase runs in a separate container)
if [ -d "$HOME/.ssh" ]; then
  SSH_DIR="/tmp/.ssh-copilot-sandbox"
  mkdir -p "$SSH_DIR"
  cp "$HOME/.ssh/known_hosts" "$SSH_DIR/known_hosts" 2>/dev/null || true
  cat > "$SSH_DIR/config" <<SSH_EOF
UserKnownHostsFile $SSH_DIR/known_hosts
IdentityFile $HOME/.ssh/id_rsa
IdentityFile $HOME/.ssh/id_ed25519
SSH_EOF
  chmod 700 "$SSH_DIR"
  chmod 600 "$SSH_DIR/config" "$SSH_DIR/known_hosts" 2>/dev/null || true
  export GIT_SSH_COMMAND="ssh -F $SSH_DIR/config"
fi

# Git config — apply signing from env vars passed by host
if [ -n "${GIT_SIGNING_KEY:-}" ]; then
  git config --global commit.gpgsign "${GIT_COMMIT_GPGSIGN:-true}"
  git config --global gpg.format "${GIT_GPG_FORMAT:-ssh}"

  if [ "${GIT_GPG_FORMAT:-ssh}" = "ssh" ]; then
    if [ -f "$GIT_SIGNING_KEY" ]; then
      git config --global user.signingkey "$GIT_SIGNING_KEY"
      PUBKEY_FILE="${GIT_SIGNING_KEY}.pub"
    elif [ -f "$HOME/.ssh/id_ed25519" ]; then
      git config --global user.signingkey "$HOME/.ssh/id_ed25519"
      PUBKEY_FILE="$HOME/.ssh/id_ed25519.pub"
    fi
    if [ -f "${PUBKEY_FILE:-}" ]; then
      ALLOWED_SIGNERS="/tmp/allowed_signers"
      GIT_EMAIL="$(git config --global user.email 2>/dev/null || echo "copilot-sandbox@local")"
      ( umask 077 && echo "$GIT_EMAIL $(cat "$PUBKEY_FILE")" > "$ALLOWED_SIGNERS" )
      git config --global gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS"
    fi
  else
    git config --global user.signingkey "$GIT_SIGNING_KEY"
  fi
fi

# Source SDKMAN
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Generate language instruction if configured
LANGUAGE_CONFIG="/opt/copilot-sandbox/config/language"
LANGUAGE_INSTRUCTION="$HOME/.copilot/instructions/copilot-sandbox-language.instructions.md"
if [ -f "$LANGUAGE_CONFIG" ]; then
  COPILOT_LANG="$(cat "$LANGUAGE_CONFIG")"
  mkdir -p "$(dirname "$LANGUAGE_INSTRUCTION")"
  {
    printf 'Always respond in %s, regardless of the language the user writes in.\n' "$COPILOT_LANG"
    printf 'This applies to ALL parts of your output: reasoning, thinking, explanations, summaries, code comments, commit messages, and any other text you generate.\n'
  } > "$LANGUAGE_INSTRUCTION"
fi

# ~/bin tem precedência no PATH (útil para overrides locais)
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

exec "$@"
