# Git-aware Prompt Configuration (NY Taxi Palette)
YELLOW='\[\e[1;33m\]'
GRAY='\[\e[38;5;244m\]'
RESET='\[\e[0m\]'

if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    # shellcheck source=/dev/null
    source /usr/share/git/completion/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1
    PROMPT_COMMAND='__prompt_git="$(__git_ps1 " [%s]")"'
    PS1="${YELLOW}\W${RESET}${GRAY}\${__prompt_git}${RESET} \$ "
else
    PS1="${YELLOW}\W${RESET} \$ "
fi
