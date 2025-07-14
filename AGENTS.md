Goal: A WSL (Windows Subsystem for Linux) distro usable on Windows machines that replicates the environment provided by the ChatGPT Codex Environment Editor Interactive Shell.

As provided by interactive shell access of the Environment Editor : 
```
https://chatgpt.com/codex/settings/environment/<identifier>/edit
```

- Everything other than the cloning of the repo

At the very least, utilize the following references:
- Codex-Shell-Execution-Order.md
- https://github.com/openai/codex-universal.git

This repo need not contain all of the files but rather the ability to generate the a binary release.

## **Startup Notes**

- Errors occur on login
```
==================================
Welcome to openai/codex-universal!
==================================
/etc/profile: line 31: /nvm.sh: No such file or directory
Configuring language runtimes...
Environment ready. Dropping you into a bash shell.
bash: /nvm.sh: No such file or directory
root@xps-ne:/mnt/c/Users/phdyex#
```
- No provision has been made to provide the CODEX_* environment variables normally provided on the docker run command line.
- No provision has been made to provide the environment variables baked into the docket image via ENV commands in the DocketFile.
- /opt/entrypoint.sh has run but /opt/codex/setup_universal.sh has not.
- `bash: /nvm.sh: No such file or directory` is due to PYENV_ROOT not being defined in the environent.
- Only two files have any mention of Codex:
  - /opt/entrypoint.sh
  - /opt/codes/setup_universal.sh
- There is no symlink /etc/profile.d/setup_universal.sh to /opt/codes/setup_universal.sh

**Files**
- Added `original-files` to this repo with relevant and potentialy releveant files for reference.
  These files should not be modified in any way.
- Updated system configuraiton files and/or scripts for the purpose of this repo's goals should be appropriately placed under <project-root>/rootfs/{etc,opt}
