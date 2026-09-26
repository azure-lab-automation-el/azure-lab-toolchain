# syntax=docker/dockerfile:1
# Azure lab toolchain: pinned azure-cli + bicep + gh + rclone on a slim base.
# Multi-stage: venv built once, no pip/build tooling in the final image.
FROM python:3.12-slim-bookworm AS azbuild
RUN python -m venv /opt/azcli \
 && /opt/azcli/bin/pip install --no-cache-dir --disable-pip-version-check azure-cli \
 && find /opt/azcli -type d -name '__pycache__' -prune -exec rm -rf {} + \
 && find /opt/azcli -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete

FROM debian:bookworm-slim AS tools
ARG BICEP_VERSION=v0.47.16
ARG RCLONE_VERSION=v1.71.1
ARG GH_VERSION=2.97.0
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && curl -fsSL -o /usr/local/bin/bicep "https://github.com/Azure/bicep/releases/download/${BICEP_VERSION}/bicep-linux-x64" \
 && curl -fsSL -o /tmp/r.zip "https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip" \
 && unzip -qj /tmp/r.zip '*/rclone' -d /usr/local/bin \
 && curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" | tar -xz --strip-components=2 -C /usr/local/bin "gh_${GH_VERSION}_linux_amd64/bin/gh" \
 && chmod +x /usr/local/bin/bicep /usr/local/bin/rclone /usr/local/bin/gh \
 && rm -rf /tmp/* /var/lib/apt/lists/*

FROM python:3.12-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends git jq curl ca-certificates openssh-client \
 && rm -rf /var/lib/apt/lists/*
COPY --from=azbuild /opt/azcli /opt/azcli
COPY --from=tools /usr/local/bin/ /usr/local/bin/
ENV PATH="/opt/azcli/bin:$PATH" AZURE_CORE_NO_SURVEY=1
WORKDIR /work
CMD ["bash"]
