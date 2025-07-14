#!/usr/bin/env bash
set -euo pipefail

# Build script for a WSL rootfs replicating the ChatGPT Codex environment.
# It clones the codex-universal repository, builds the Docker image, exports
# the container filesystem, and injects environment initialization files so
# that the resulting tarball can be imported directly with `wsl`.

REPO_URL="https://github.com/openai/codex-universal.git"
REPO_DIR="codex-universal"
IMAGE_NAME="codex-universal-wsl"
ROOTFS_TAR="codex-wsl-rootfs.tar"

# Clone the upstream repository if it doesn't already exist
if [ ! -d "$REPO_DIR" ]; then
    ( set -x && git clone "$REPO_URL" "$REPO_DIR" )
fi

# Build the Docker image containing the Codex environment
( set -x && cd "$REPO_DIR" && docker build -t "$IMAGE_NAME" . )
# cd - >/dev/null

# Create a container from the image and export its filesystem
_create="docker create '$IMAGE_NAME' /bin/bash"
echo "+ ${_create}"
CID=$( ${_create} )
( set =x && docker export "$CID" -o "$ROOTFS_TAR" )
( set -x && docker rm "$CID" )

# Inject environment variables and setup script sourcing
TMPDIR=$(mktemp -d)
( set -x && tar -xf "$ROOTFS_TAR" -C "$TMPDIR" )
( set -x && mkdir -p "$TMPDIR/etc/profile.d" )
( set -x && cat > "$TMPDIR/etc/profile.d/codex_env.sh" ) <<'EOS'
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

( set -x && tar -C "$TMPDIR" -cf "$ROOTFS_TAR" . )
( set -x && rm -rf "$TMPDIR" )

( set -x && gzip -f "$ROOTFS_TAR" )

echo "Created $(pwd)/${ROOTFS_TAR}.gz"
