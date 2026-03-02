FROM node:24-slim

LABEL maintainer="william.correa@devitools.com.br"
LABEL description="Copilot Sandbox - Docker container for GitHub Copilot CLI"

# Install minimal packages needed for CA cert setup and subsequent steps
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install remaining system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gnupg \
    wget \
    unzip \
    zip \
    build-essential \
    jq \
    python3 \
    python3-venv \
    sed \
    openssh-client \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
       dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
       tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Docker CLI only (no daemon needed — we mount the host socket)
# Uses TARGETARCH (set automatically by BuildKit) for cross-platform builds.
ARG TARGETARCH
RUN case "${TARGETARCH:-amd64}" in \
      amd64) DOCKER_ARCH="x86_64" ; COMPOSE_ARCH="x86_64" ;; \
      arm64) DOCKER_ARCH="aarch64" ; COMPOSE_ARCH="aarch64" ;; \
      *)     DOCKER_ARCH="${TARGETARCH}" ; COMPOSE_ARCH="${TARGETARCH}" ;; \
    esac \
    && curl -fsSL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-27.5.1.tgz" -o docker.tgz \
    && tar -xzf docker.tgz --strip-components=1 -C /usr/local/bin docker/docker \
    && rm docker.tgz \
    && docker --version \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -fsSL "https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-${COMPOSE_ARCH}" \
       -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
    && docker compose version

# Install AWS CLI v2
RUN case "${TARGETARCH:-amd64}" in \
      amd64) AWS_ARCH="x86_64" ;; \
      arm64) AWS_ARCH="aarch64" ;; \
      *)     AWS_ARCH="x86_64" ;; \
    esac \
    && curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o awscliv2.zip \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip \
    && aws --version

# Install uv (Python package manager, includes uvx)
# Pinned to a specific version to avoid supply-chain risk from mutable :latest tag.
COPY --from=ghcr.io/astral-sh/uv:0.10.4 /uv /uvx /usr/local/bin/

# Install SDKMAN
ENV SDKMAN_DIR="/root/.sdkman"
ENV PATH="$SDKMAN_DIR/bin:$PATH"
RUN curl -s "https://get.sdkman.io" | bash \
    && bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh \
    && sdk version"

# Persistent cache directory (mounted from host ~/.copilot-sandbox)
RUN mkdir -p /opt/copilot-sandbox

# Allow non-root users to register themselves in /etc/passwd at runtime.
# Required when running with --user UID:GID where the UID doesn't exist in the
# image. Tools like git, ssh, and Node.js fail without a valid passwd entry.
# World-writable is necessary because the UID is arbitrary and has no pre-existing
# group membership in the image. The container is ephemeral and single-user.
RUN chmod 666 /etc/passwd /etc/group

# Copy Copilot customizations
COPY container/instructions/ /opt/copilot-sandbox/instructions/
COPY container/skills/ /opt/copilot-sandbox/skills/

# Copy scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY user-entrypoint.sh /usr/local/bin/user-entrypoint.sh
COPY bin/jira bin/http bin/confluence bin/arandu bin/xdg-open bin/docker-compose /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh /usr/local/bin/user-entrypoint.sh \
    /usr/local/bin/jira /usr/local/bin/http /usr/local/bin/confluence \
    /usr/local/bin/arandu /usr/local/bin/xdg-open /usr/local/bin/docker-compose

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["copilot"]
