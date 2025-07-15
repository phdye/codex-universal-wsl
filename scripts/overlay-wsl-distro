#!/usr/bin/env python3
"""Create a WSL-compatible Codex distro tarball.

Usage:
  overlay-wsl-distro.sh [--no-overlay]
  overlay-wsl-distro.sh (-h | --help)
  overlay-wsl-distro.sh --version

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
        description="Create a WSL-compatible Codex distro tarball.",
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

    ROOT_DIR = Path(__file__).resolve().parent
    BASE_REPO = ROOT_DIR / "codex-universal"
    OVERLAY_DIR = ROOT_DIR / "rootfs"
    OUTPUT_DIR = ROOT_DIR / "build" / "rootfs"
    TARBALL = ROOT_DIR / "codex-universal-wsl.tar.gz"

    if not BASE_REPO.exists():
        print("codex-universal submodule not found. Run 'git submodule update --init --depth 1'", flush=True)
        raise SystemExit(1)

    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True)

    base_fs = BASE_REPO / "rootfs"
    if base_fs.is_dir():
        run(["cp", "-a", str(base_fs / "."), str(OUTPUT_DIR)])
    else:
        print(f"Base repo missing rootfs: {base_fs}")
        raise SystemExit(1)

    if overlay:
        run(["cp", "-a", f"{OVERLAY_DIR}/.", str(OUTPUT_DIR)])

    run(["tar", "--numeric-owner", "-C", str(OUTPUT_DIR), "-czf", str(TARBALL), "."])
    print(f"WSL distro created: {TARBALL}")


if __name__ == "__main__":
    main()
