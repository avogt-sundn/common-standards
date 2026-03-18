#!/usr/bin/env bash
# Install Cypress binary for interactive test development in the devcontainer.
# The Linux shared libraries are installed in the Dockerfile.
# This script runs after npm install so the node_modules/cypress binary is present.

set -e

echo "Installing Cypress binary..."

cd /workspaces/traefik-lb/tests

# Install npm deps for the tests project (cypress package + junit reporter)
npm install

# Download the Cypress binary into ~/.cache/Cypress
npx cypress install

# Verify the install
npx cypress verify

echo "Cypress is ready. Run tests interactively with:"
echo "  cd /workspaces/traefik-lb/tests && CYPRESS_BASE_URL=https://gateway npx cypress open"
echo "  cd /workspaces/traefik-lb/tests && CYPRESS_BASE_URL=https://gateway npx cypress run"
