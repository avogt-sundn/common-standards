#!/usr/bin/env bash

# devcontainer post-create hook
set -e
echo "Claude Code ..."

sudo chown -R vscode:vscode /home/vscode/.aws

npm install -g @anthropic-ai/claude-code \
    && curl -fsSL https://claude.ai/install.sh | bash


echo "Claude Code CLI is set up"
