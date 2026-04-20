FROM ghcr.io/actions/actions-runner:latest

USER root
RUN mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
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
