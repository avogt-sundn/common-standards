 # See here for image contents: https://github.com/microsoft/vscode-dev-containers/blob/main/containers/java/.devcontainer/base.Dockerfile
# [Choice] Java version (use -bullseye variants on local arm64/Apple Silicon): 8, 11, 17, 8-bullseye, 11-bullseye, 17-bullseye, 8-buster, 11-buster, 17-buster
FROM mcr.microsoft.com/devcontainers/java:dev-25-jdk-bookworm

# Avoid warnings by switching to noninteractive
# ENV DEBIAN_FRONTEND=noninteractive

ENV IGNORE_NOTICE=true
# BEGIN ------ install common utils: ping, dig, ncat, pip, yq
RUN apt update && apt install -y iputils-ping dnsutils file apache2-utils python3-pip httpie telnet
#RUN pip install yq
#   END ------ install common utils: ping, dig, ncat, pip, yq

# BEGIN plantuml extension
#RUN apt update && apt install -y graphviz
# END   plantuml extension

# set workspace directory
WORKDIR /home/vscode

RUN ARCH=$(uname -m) \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# ── Cypress Linux dependencies ─────────────────────────────────────────────
# Required to run Cypress headlessly inside the devcontainer for interactive
# test development. The binary itself is downloaded via postCreate-Cypress.sh.
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    libglib2.0-0 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libasound2 \
    libxtst6 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libpango-1.0-0 \
    libcairo2 \
    && rm -rf /var/lib/apt/lists/*
