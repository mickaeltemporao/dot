# Git-aware Prompt Configuration
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    # shellcheck source=/dev/null
    source /usr/share/git/completion/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1

    BLUE='\[\e[34m\]'
    GRAY='\[\e[37m\]'
    RESET='\[\e[0m\]'

    PROMPT_COMMAND='__prompt_git="$(__git_ps1 " [%s]")"'
    PS1="${BLUE}\W${RESET}${GRAY}\${__prompt_git}${RESET} \$ "
fi
