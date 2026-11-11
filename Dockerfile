# Wersja runnera przypieta - aktualizuje ja Renovate (PR po kazdym release actions/runner).
# GitHub odrzuca zbyt stare runnery (ARC: faza Outdated), wiec obraz musi nadazac za release'ami.
FROM ghcr.io/actions/actions-runner:2.338.2

# renovate: datasource=github-releases depName=docker/compose
ARG DOCKER_COMPOSE_VERSION=v5.7.1

USER root

# Install gh CLI, jq, python3 (used by workflows for GitHub API access, JSON parsing, scripting)
# libatomic1: Node.js 26+ jest dynamicznie linkowany z libatomic.so.1 (Node 22 nie). Bez niej `node` z actions/setup-node konczy sie kodem 127.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
       https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh jq python3 libatomic1 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -fSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
       -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Wrapper buildx — injects --config for org-wide registry mirror
# Docker calls plugin as: docker-buildx buildx create ... ($1=buildx, $2=create)
RUN mv /usr/local/lib/docker/cli-plugins/docker-buildx \
       /usr/local/lib/docker/cli-plugins/docker-buildx.real
RUN printf '#!/bin/sh\nREAL=/usr/local/lib/docker/cli-plugins/docker-buildx.real\nCONFIG=/home/runner/.docker/buildx/buildkitd.toml\nif [ "$2" = "create" ] && [ -f "$CONFIG" ]; then\n    has_config=0\n    for arg in "$@"; do [ "$arg" = "--config" ] && has_config=1 && break; done\n    [ "$has_config" = "0" ] && exec "$REAL" "$@" --config "$CONFIG"\nfi\nexec "$REAL" "$@"\n' > /usr/local/lib/docker/cli-plugins/docker-buildx \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
USER runner

ENTRYPOINT ["/home/runner/run.sh"]
