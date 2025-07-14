# Locale
export LANG="C.UTF-8"

# Global pyenv shared install
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init - bash)"

# pipx — user-local
export PIPX_BIN_DIR="$HOME/.local/bin"
export PATH="$PIPX_BIN_DIR:$PATH"

# uv
export UV_NO_PROGRESS=1

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Corepack
export COREPACK_DEFAULT_TO_LATEST=0
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export COREPACK_ENABLE_AUTO_PIN=0
export COREPACK_ENABLE_STRICT=0

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Gradle (global)
export GRADLE_HOME="/opt/gradle"
export PATH="$GRADLE_HOME/bin:$PATH"

# Go (global + user workspace)
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"

# Swiftly
[ -s "$HOME/.local/share/swiftly/env.sh" ] && . "$HOME/.local/share/swiftly/env.sh"
