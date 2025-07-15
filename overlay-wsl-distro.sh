#!/usr/bin/env bash

# Build a WSL-compatible Codex distro tarball.
# This script assumes the `codex-universal` submodule is initialized.

set -euo pipefail

_rootfs=yes
if [ "$1" == "--no-rootfs" ] ; then
    _rootfs=
fi

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_REPO="$ROOT_DIR/codex-universal"
OVERLAY_DIR="$ROOT_DIR/rootfs"
OUTPUT_DIR="$ROOT_DIR/build/rootfs"
TARBALL="$ROOT_DIR/codex-universal-wsl.tar.gz"

if [ ! -d "$BASE_REPO" ]; then
    echo "codex-universal submodule not found. Run 'git submodule update --init --depth 1'" >&2
    exit 1
fi

# Prepare output directory
( set -x && rm -rf "$OUTPUT_DIR" && mkdir -p "$OUTPUT_DIR" )

# Copy base filesystem
if [ -d "$BASE_REPO/rootfs" ]; then
    ( set -x && cp -a "$BASE_REPO/rootfs/." "$OUTPUT_DIR/" )
fi

# # Overlay custom rootfs files
if 
# ( set -x && cp -a "$OVERLAY_DIR/." "$OUTPUT_DIR/" )

# Create tarball
( set -x && rm -f "$TARBALL" && tar --numeric-owner -C "$OUTPUT_DIR" -czf "$TARBALL" . )

echo "WSL distro created: $TARBALL"
