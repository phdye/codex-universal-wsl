# Codex Universal WSL Builder

This repository provides scripts and instructions for building or installing a WSL distribution that mirrors the ChatGPT Codex environment.

A Docker based build script is included for creating a root filesystem tarball from the public [openai/codex-universal](https://github.com/openai/codex-universal) repository.  For convenience on Windows, a separate script imports the latest GitHub release directly using `wsl.exe` from a Cygwin shell.

## Requirements

- Docker (for building the rootfs)
- Git
- On Windows: Cygwin with `curl` and access to the `wsl.exe` command

## Building the Rootfs

Run the build script from any Unix environment with Docker installed:

```bash
./build_codex_wsl.sh
```

This clones `openai/codex-universal` if needed, builds the Docker image, exports a container filesystem, and injects environment initialization files so that the resulting `codex-wsl-rootfs.tar.gz` behaves like the Codex shell.

## Installing on Windows

From a Cygwin terminal, execute the installer script which downloads the binary release and uses `wsl.exe` to import the distribution:

```bash
./create_codex_wsl.sh
```

By default the distribution is imported as `CodexEnv` under `~/CodexEnv`. Pass `DISTRO_NAME` and `INSTALL_DIR` environment variables to override these paths.

## Environment Details

Initialization follows the order described in `Codex-Shell-Execution-Order.md`.  Docker `ENV` variables and typical `CODEX_ENV_*` values are written to `/etc/profile.d/codex_env.sh` inside the distribution so they are available whenever the shell starts.
