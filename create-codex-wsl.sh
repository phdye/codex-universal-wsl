#!/usr/bin/env python3
"""Download the latest Codex WSL rootfs release and import it using `wsl`.

Usage:
  create-codex-wsl.sh [--release-url URL] [--distro-name NAME] [--distro-base DIR]
  create-codex-wsl.sh (-h | --help)
  create-codex-wsl.sh --version

Options:
  --release-url URL  URL of the rootfs tarball [default: https://github.com/openai/codex-universal/releases/latest/download/codex-wsl-rootfs.tar.gz]
  --distro-name NAME Name of the WSL distribution [default: Codex-Universal]
  --distro-base DIR  Directory where the distro will be installed [default: /mnt/c/wsl]
  -h --help          Show this help message and exit.
  --version          Show version.
"""
import argparse
import subprocess
from pathlib import Path

VERSION = "1.0"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Download the latest Codex WSL rootfs release and import it using wsl",
        add_help=False,
    )
    parser.add_argument("--release-url", default="https://github.com/openai/codex-universal/releases/latest/download/codex-wsl-rootfs.tar.gz", help="URL of the rootfs tarball")
    parser.add_argument("--distro-name", default="Codex-Universal", help="Name of the WSL distribution")
    parser.add_argument("--distro-base", default="/mnt/c/wsl", help="Installation base directory")
    parser.add_argument("--version", action="version", version=VERSION)
    parser.add_argument("-h", "--help", action="help", help="Show this help message and exit")
    return parser.parse_args()


def run(cmd, **kwargs):
    print("+", " ".join(cmd))
    subprocess.run(cmd, check=True, **kwargs)


def main():
    args = parse_args()
    tarball = Path("codex-wsl-rootfs.tar.gz")
    install_dir = Path(args.distro_base) / args.distro_name

    if not tarball.exists():
        run(["curl", "-L", "-o", str(tarball), args.release_url])

    run(["mkdir", "-p", str(install_dir)])
    run([
        "wsl.exe",
        "--import",
        args.distro_name,
        str(install_dir),
        str(tarball),
        "--version",
        "2",
    ])
    print(f"Imported WSL distribution '{args.distro_name}'")


if __name__ == "__main__":
    main()
