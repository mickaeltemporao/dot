export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="st"
export BROWSER="firefox"
export XDG_CONFIG_HOME="$HOME/.config"
export PASSWORD_STORE_DIR="$XDG_CONFIG_HOME/passwords"

# R Library Folder (for Nvim-R)
export R_LIBS_USER="$HOME/.local/share/r-libs"

# User PATH Additions
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/bin:$PATH"

# Pyenv initialization (path)
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
fi

# Source interactive bash configuration if running interactively under bash
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    case "$-" in
        *i*) . "$HOME/.bashrc" ;;
    esac
fi

# Auto-start X11 on TTY1 login
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR:-0}" -eq 1 ]; then
    exec startx
fi
