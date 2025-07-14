# Codex Universal WSL

This repository packages the [openai/codex-universal](https://github.com/openai/codex-universal) image into a
WSL distributable. The `rootfs` directory contains configuration files that
mirror the environment of the Codex Environment Editor.

## Prerequisites

* Initialize the `codex-universal` submodule:

```bash
git submodule update --init --depth 1
```

The submodule provides the base filesystem used to build the WSL tarball.

## Building the WSL Distribution

Run the build script to generate a tarball that can be imported with `wsl.exe`:

```bash
./build-wsl-distro.sh
```

The script creates `codex-universal-wsl.tar.gz` in the project root.  Files
under `rootfs/` are overlaid on top of the vanilla
`openai/codex-universal` filesystem from the submodule, ensuring that any
custom configuration in this repository becomes part of the resulting WSL
distro.

Import the tarball on Windows using:

```powershell
wsl --import CodexUniversal <install-path> .\codex-universal-wsl.tar.gz
```

