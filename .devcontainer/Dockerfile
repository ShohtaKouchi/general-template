# syntax=docker/dockerfile:1

# Dockerfile for Dev Container
#
# This Dockerfile configures a Dev Container for the project.

FROM mcr.microsoft.com/devcontainers/base:bookworm

# Install Node.js.
RUN --mount=type=bind,source=.devcontainer/installers/install_nodejs.sh,target=/tmp/install_nodejs.sh \
	--mount=type=bind,source=.nvmrc,target=/tmp/.nvmrc \
	/tmp/install_nodejs.sh --nvmrc-path /tmp/.nvmrc

RUN apt-get update && apt-get install -y  --no-install-recommends \
    shellcheck=0.9.0-1 \
    shfmt=3.6.0-* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
