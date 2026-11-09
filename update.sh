#!/bin/bash
#
# Pulls the latest version from Git and reinstalls it.
# Must be run from the cloned repository, not from /opt/led-wayland.

set -euo pipefail

repo_dir=$(dirname "$(readlink -f "$0")")

if [ ! -d "$repo_dir/.git" ]
then
    echo "Error: update.sh must be run from the cloned repository" >&2
    exit 1
fi

git -C "$repo_dir" pull --ff-only

exec sudo "$repo_dir/install.sh"
