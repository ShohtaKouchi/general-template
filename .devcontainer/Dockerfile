# syntax=docker/dockerfile:1

# Dockerfile for Dev Container
#
# This Dockerfile configures a Dev Container for the project.

FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN apt-get update && apt-get install -y  --no-install-recommends \
    shellcheck=0.9.0-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
