# ~/.bash_profile - macOS / Login Shell Initialization
# macOS terminal emulators (Ghostty, Terminal.app, iTerm2) spawn login shells by default.
# Ensure environment variables and modular interactive configs are loaded:

# Add Homebrew to PATH on macOS (Apple Silicon / Intel)
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
