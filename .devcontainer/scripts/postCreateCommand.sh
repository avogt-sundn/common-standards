#!/usr/bin/env bash

set -euo pipefail

scriptdir="$(cd "$(dirname "$0")" && pwd)"
workspace_dir="${containerWorkspaceFolder:-$(pwd)}"
scripts_path="$workspace_dir/.devcontainer/scripts"

# Add scripts to PATH once for interactive shells in the container.
if ! grep -Fq "$scripts_path" /home/vscode/.zshrc; then
	echo "export PATH=\"\$PATH:$scripts_path\"" >> /home/vscode/.zshrc
fi

bash "$scriptdir/postCreate-Quarkus.sh"
bash "$scriptdir/postCreate-Maven.sh"
bash "$scriptdir/postCreate-Claude.sh"

echo "Done devcontainering."
# source $scriptdir/postCreate-Claude.sh
