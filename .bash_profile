# ~/.bash_profile - macOS / Login Shell Initialization
# macOS terminal emulators (Ghostty, Terminal.app, iTerm2) spawn login shells by default.
# Ensure environment variables and modular interactive configs are loaded:

if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
