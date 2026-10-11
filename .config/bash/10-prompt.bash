# Git-aware Prompt Configuration (NY Taxi Palette)
YELLOW='\[\e[1;33m\]'
GRAY='\[\e[38;5;244m\]'
RESET='\[\e[0m\]'

GIT_PROMPT_SRC=""
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    GIT_PROMPT_SRC="/usr/share/git/completion/git-prompt.sh"
elif [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "${HOMEBREW_PREFIX}/etc/bash_completion.d/git-prompt.sh" ]; then
    GIT_PROMPT_SRC="${HOMEBREW_PREFIX}/etc/bash_completion.d/git-prompt.sh"
fi

if [ -n "$GIT_PROMPT_SRC" ]; then
    # shellcheck source=/dev/null
    source "$GIT_PROMPT_SRC"
    export GIT_PS1_SHOWDIRTYSTATE=1
    PROMPT_COMMAND='__prompt_git="$(__git_ps1 " [%s]")"'
    PS1="${YELLOW}\W${RESET}${GRAY}\${__prompt_git}${RESET} \$ "
else
    PS1="${YELLOW}\W${RESET} \$ "
fi
