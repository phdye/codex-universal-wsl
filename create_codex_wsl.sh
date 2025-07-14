#!/usr/bin/env bash
set -euo pipefail

# Script for Cygwin to download the latest Codex WSL rootfs release and import it
# using the Windows `wsl` command.

RELEASE_URL=${RELEASE_URL:-"https://github.com/openai/codex-universal/releases/latest/download/codex-wsl-rootfs.tar.gz"}
DISTRO_NAME=${DISTRO_NAME:-CodexEnv}
INSTALL_DIR=${INSTALL_DIR:-"$HOME/$DISTRO_NAME"}
TARBALL="codex-wsl-rootfs.tar.gz"

# Download the release tarball
curl -L -o "$TARBALL" "$RELEASE_URL"

# Import the distribution via wsl.exe
mkdir -p "$INSTALL_DIR"
wsl.exe --import "$DISTRO_NAME" "$(cygpath -w "$INSTALL_DIR")" "$(cygpath -w "$TARBALL")" --version 2

echo "Imported WSL distribution '$DISTRO_NAME'"
