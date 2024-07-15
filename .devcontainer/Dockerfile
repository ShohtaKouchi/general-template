# syntax=docker/dockerfile:1

# Dockerfile for Dev Container
#
# This Dockerfile configures a Dev Container for the project.

FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN nodejs_setup=$(mktemp) && curl -fsSL -o $nodejs_setup https://deb.nodesource.com/setup_22.x \
    && bash $nodejs_setup \
    && rm $nodejs_setup
RUN apt-get update && apt-get install -y  --no-install-recommends \
    nodejs=22.4.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@9.5
