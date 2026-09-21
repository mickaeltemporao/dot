# Bash Completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    # shellcheck source=/dev/null
    source /usr/share/bash-completion/completions/git
    __git_complete dot __git_main
fi

# Homebrew environment & completions (macOS)
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    if [ -s "${HOMEBREW_PREFIX:-}/etc/profile.d/bash_completion.sh" ]; then
        # shellcheck source=/dev/null
        source "${HOMEBREW_PREFIX:-}/etc/profile.d/bash_completion.sh"
    fi
fi
