#!/usr/bin/env bash
set -euo pipefail

# Script for Cygwin to download the latest Codex WSL rootfs release and import it
# using the Windows `wsl` command.

# RELEASE_URL=${RELEASE_URL:-"https://github.com/openai/codex-universal/releases/latest/download/codex-wsl-rootfs.tar.gz"}
DISTRO_NAME=${DISTRO_NAME:-Codex-Universal}
# INSTALL_DIR=${INSTALL_DIR:-"$HOME/wsl/$DISTRO_NAME"}
TARBALL="codex-wsl-rootfs.tar.gz"

# Alternatively, make a sibling of the current distro ?
# CURRENT_DISTRO_PATH=$(cygpath -m -a $(distro-path .))
# if ${CURRENT_DISTRO_PATH} ends with /LocalState
#    CURRENT_DISTRO_PATH=$(dirname ${CURRENT_DISTRO_PATH})
# fi
# DISTRO_BASE=$(dirname ${CURRENT_DISTRO_PATH})
DISTRO_BASE="/mnt/c/wsl"

INSTALL_DIR="${DISTRO_BASE}/${DISTRO_NAME}"

# Download the release tarball
if [ ! -f "$TARBALL" ] ; then
     ( set -x && curl -L -o "$TARBALL" "$RELEASE_URL" )
fi

# Import the distribution via wsl.exe
( set -x && mkdir -p "$INSTALL_DIR" )
( set -x && wsl.exe --import "$DISTRO_NAME" "$(cygpath -w "$INSTALL_DIR")" "$(cygpath -w "$TARBALL")" --version 2 )

echo "Imported WSL distribution '$DISTRO_NAME'"
