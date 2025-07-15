#!/usr/bin/env python3
"""Build a WSL rootfs replicating the ChatGPT Codex environment.

Usage:
  build-codex-wsl.sh [--no-overlay]
  build-codex-wsl.sh (-h | --help)
  build-codex-wsl.sh --version

Options:
  --no-overlay    Do not overlay custom rootfs files [default: False]
  -h --help       Show this help message and exit.
  --version       Show version.
"""
import argparse
import shutil
import subprocess
from pathlib import Path

VERSION = "1.0"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Build a WSL rootfs replicating the ChatGPT Codex environment.",
        add_help=False,
    )
    parser.add_argument("--no-overlay", action="store_true", help="Do not overlay custom rootfs files")
    parser.add_argument("--version", action="version", version=VERSION)
    parser.add_argument("-h", "--help", action="help", help="Show this help message and exit")
    return parser.parse_args()


def run(cmd, **kwargs):
    print("+", " ".join(cmd))
    subprocess.run(cmd, check=True, **kwargs)


def main():
    args = parse_args()
    overlay = not args.no_overlay

    REPO_URL = "https://github.com/openai/codex-universal.git"
    REPO_NAME = "codex-universal"
    REPO_DIR = Path(REPO_NAME)
    IMAGE_NAME = "codex-universal-wsl"

    ROOT_DIR = Path(__file__).resolve().parent
    ARCHIVE_DIR = ROOT_DIR / "archive"
    BASE_ROOTFS_TAR = ARCHIVE_DIR / f"{REPO_NAME}.rootfs.tar"
    BASE_REPO = ROOT_DIR / REPO_NAME
    OVERLAY_DIR = ROOT_DIR / "rootfs"
    OUTPUT_DIR = ROOT_DIR / "build" / "rootfs"
    ROOTFS_TAR = f"{IMAGE_NAME}.tar.xz"

    ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True)

    if not REPO_DIR.exists():
        run(["git", "submodule", "update", "--init", "--depth", "1"])

    run(["docker", "build", "-t", IMAGE_NAME, "."], cwd=str(REPO_DIR))

    cid = subprocess.check_output(["docker", "create", IMAGE_NAME, "/bin/bash"]).decode().strip()
    run(["docker", "export", cid, "-o", str(BASE_ROOTFS_TAR)])
    run(["docker", "rm", cid])

    run(["tar", "-xf", str(BASE_ROOTFS_TAR), "-C", str(OUTPUT_DIR)])
    (OUTPUT_DIR / "etc" / "profile.d").mkdir(parents=True, exist_ok=True)
    env_file = OUTPUT_DIR / "etc" / "profile.d" / "codex_env.sh"
    env_file.write_text(
        """export LANG=${LANG:-C.UTF-8}
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
"""
    )

    if overlay:
        run(["cp", "-a", f"{OVERLAY_DIR}/.", str(OUTPUT_DIR)])

    run(["tar", "-C", str(OUTPUT_DIR), "-cfJ", ROOTFS_TAR, "."])
    print(f"Created {ROOT_DIR / ROOTFS_TAR}")


if __name__ == "__main__":
    main()
