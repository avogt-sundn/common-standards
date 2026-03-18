#!/usr/bin/env bash

scriptdir="$(dirname "$0")"
echo $scriptdir
pwd
set -e

echo \"export PATH='$PATH':/workspaces/${localWorkspaceFolderBasename}/.devcontainer/scripts\" >> /home/vscode/.zshrc

sh $scriptdir/postCreate-Quarkus.sh
sh $scriptdir/postCreate-Maven.sh
sh $scriptdir/postCreate-Claude.sh
sh $scriptdir/postCreate-Cypress.sh

echo "Done devcontainering."
# source $scriptdir/postCreate-Claude.sh
