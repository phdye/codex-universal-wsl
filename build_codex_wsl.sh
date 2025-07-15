#!/usr/bin/env bash
set -euo pipefail

# Build script for a WSL rootfs replicating the ChatGPT Codex environment.
# It clones the codex-universal repository, builds the Docker image, exports
# the container filesystem, and injects environment initialization files so
# that the resulting tarball can be imported directly with `wsl`.

REPO_URL="https://github.com/openai/codex-universal.git"
REPO_NAME="codex-universal"
REPO_DIR=${REPO_NAME}
IMAGE_NAME="codex-universal-wsl"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE_DIR="$ROOT_DIR/archive"
BASE_ROOTFS_TAR="${ARCHIVE_DIR}/${REPO_NAME}.rootfs.tar"
BASE_REPO="$ROOT_DIR/${REPO_NAME}"
OVERLAY_DIR="$ROOT_DIR/rootfs"
OUTPUT_DIR="$ROOT_DIR/build/rootfs"
ROOTFS_TAR="${IMAGE_NAME}.tar.xz"

_overlay=yes
if [ $# -gt 0 ] ; then
    if [ "$1" == "--no-overlay" ] ; then
        _overlay=
        shift
    fi
fi

# X Clone the upstream repository if it doesn't already exist
# Update submodule, if necessary
if [ ! -d "$REPO_DIR" ]; then
    # ( set -x && git clone "$REPO_URL" "$REPO_DIR" )
    ( set -x && git submodule update --init --depth 1 )
fi

# Build the Docker image containing the Codex environment
( set -x && cd "$REPO_DIR" && docker build -t "$IMAGE_NAME" . )

# Create a container from the image and export its filesystem
_create="docker create $IMAGE_NAME /bin/bash"
echo "+ ${_create}"
CID=$( ${_create} )
( set =x && docker export "$CID" -o "$BASE_ROOTFS_TAR" )
( set -x && docker rm "$CID" )

# Inject environment variables and setup script sourcing
( set -x && tar -xf "$BASE_ROOTFS_TAR" -C "$OUTPUT_DIR" )
( set -x && mkdir -p "$OUTPUT_DIR/etc/profile.d" )
( set -x && cat > "$OUTPUT_DIR/etc/profile.d/codex_env.sh" ) <<'EOS'
export LANG=${LANG:-C.UTF-8}
export LC_ALL=${LC_ALL:-C.UTF-8}
export CODEX_ENV_PYTHON_VERSION=${CODEX_ENV_PYTHON_VERSION:-3.12}
export CODEX_ENV_NODE_VERSION=${CODEX_ENV_NODE_VERSION:-20}
export CODEX_ENV_RUBY_VERSION=${CODEX_ENV_RUBY_VERSION:-3.4.4}
export CODEX_ENV_RUST_VERSION=${CODEX_ENV_RUST_VERSION:-1.87.0}
export CODEX_ENV_GO_VERSION=${CODEX_ENV_GO_VERSION:-1.24.3}
export CODEX_ENV_BUN_VERSION=${CODEX_ENV_BUN_VERSION:-1.2.14}
export CODEX_ENV_JAVA_VERSION=${CODEX_ENV_JAVA_VERSION:-21}
export CODEX_ENV_SWIFT_VERSION=${CODEX_ENV_SWIFT_VERSION:-6.1}

if [ -f /opt/codex/setup_universal.sh ]; then
    source /opt/codex/setup_universal.sh
fi
EOS

# Overlay custom rootfs files
if [ -n "${_overlay}" ] ; then
    ( set -x && cp -a "$OVERLAY_DIR/." "$OUTPUT_DIR/" )
fi

( set -x && tar -C "$OUTPUT_DIR" -cfJ "$ROOTFS_TAR" . )

echo "Created $(pwd)/${ROOTFS_TAR}"
