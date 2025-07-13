# Codex-Shell-Execution-Order.md

This document describes the execution order of environment variable definitions and shell initialization scripts in the Codex environment, up to the point where a user obtains interactive shell access via the Codex Environment Editor:

```

[https://chatgpt.com/codex/settings/environment/](https://chatgpt.com/codex/settings/environment/)<identifier>/edit

````

## 1. Dockerfile ENV Directives

Environment variables defined in the Codex Dockerfile using the `ENV` instruction are set first. These variables are baked into the container image at build time.

Example:

```dockerfile
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/opt/conda/bin:$PATH \
    CODEX_ENV_NAME=myenv \
    CODEX_ENV_TYPE=venv
````

## 2. Container Runtime Environment Variables

The container orchestration layer (e.g. Kubernetes) injects runtime environment variables when starting the container. These variables may include dynamically generated values such as environment IDs, user IDs, or secret references.

Examples:

```
CODEX_ENV_ID=abc123
CODEX_ACCOUNT_ID=user456
CODEX_ENVIRONMENT_PATH=/mnt/codex/envs/abc123
```

Values set here override any identical variables defined in the Dockerfile.

## 3. /etc/environment

System-wide environment variables may be defined in `/etc/environment`. In Codex containers, this file is typically minimal or empty except for default system paths.

Example:

```
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

## 4. /etc/profile

When a login shell starts, the shell reads `/etc/profile`. This file may contain system-wide environment configurations or references to scripts under `/etc/profile.d/`.

Typical contents:

```bash
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
fi
```

## 5. /etc/profile.d/\*.sh

Scripts located under `/etc/profile.d/` are sourced by `/etc/profile`. In Codex environments, these scripts include logic for environment setup. One key script is:

```
/etc/profile.d/setup_universal.sh
```

## 6. /opt/codex/setup\_universal.sh

The `/etc/profile.d/setup_universal.sh` script, typically symlinked from `/opt/codex/setup_universal.sh`, performs Codex-specific environment setup:

* Exports Codex-related environment variables such as:

  ```
  export CODEX_ENV_ROOT=/mnt/codex/envs/$CODEX_ENV_ID
  export VIRTUAL_ENV=$CODEX_ENV_ROOT/venv
  export PATH=$VIRTUAL_ENV/bin:$PATH
  ```

* Initializes virtual environments or other runtime environments as required.

* Sources user-defined environment variables stored in Codex’s environment configuration (see next section).

## 7. User-Defined Environment Variables

Users can define custom environment variables in the Codex Environment Editor UI. These variables are stored in an environment manifest (e.g., JSON or YAML). They are injected into the shell environment either:

* By appending `export` statements into `/opt/codex/setup_universal.sh`, or
* By mounting a separate file (e.g., `/opt/codex/env_vars.sh`) that is sourced from `setup_universal.sh`.

These variables become part of the environment for all shell sessions and task executions.

Example:

```
MY_SECRET_TOKEN=abc123
MY_ENV=production
```

## 8. /opt/entrypoint.sh

Codex Docker images define the container entrypoint as:

```dockerfile
ENTRYPOINT ["/opt/entrypoint.sh"]
```

The `/opt/entrypoint.sh` script:

* Determines the environment type (e.g. venv, conda).
* Sets default environment variables if not already set.
* Sources `/etc/profile`.
* Executes the target command passed to the container:

  ```
  exec "$@"
  ```

In the case of an interactive shell session, this typically results in:

```
/bin/bash --login
```

## 9. User Shell Startup Files (\~/.bash\_profile, \~/.bashrc)

When an interactive shell starts, user-specific shell configuration files are loaded:

* Login shells read `~/.bash_profile`.
* Non-login interactive shells read `~/.bashrc`.

In Codex containers, these files may include:

* Customized shell prompts.
* Aliases and helper functions.
* Additional sourcing of `/opt/codex/setup_universal.sh` if not already loaded.

Example:

```bash
export PS1="(codex) \u@\h:\w\$ "
```

---

## Summary

The order of evaluation for environment variables and shell scripts in the Codex environment is as follows:

1. Dockerfile ENV directives
2. Container runtime environment variables
3. /etc/environment
4. /etc/profile
5. /etc/profile.d/\*.sh
6. /opt/codex/setup\_universal.sh
7. User-defined environment variables from Codex Environment Editor
8. /opt/entrypoint.sh
9. User shell startup files (\~/.bash\_profile, \~/.bashrc)

This sequence ensures that both system-level and user-specific configurations are active in the shell session accessed via the Codex Environment Editor.

