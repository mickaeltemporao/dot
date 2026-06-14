# The Gitted prompt...
source /usr/share/git/completion/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1

BLUE='\[\e[34m\]'
GRAY='\[\e[37m\]'
RESET='\[\e[0m\]'

PROMPT_COMMAND='__prompt_git="$(__git_ps1 " [%s]")"'
PS1="${BLUE}\W${RESET}${GRAY}\${__prompt_git}${RESET} \$ "

alias dot="/usr/bin/git --git-dir=$HOME/.dot/ --work-tree=$HOME"
alias ls="ls -lah --color=auto"
alias grep="grep --color=auto"
alias vi="nvim"
alias vim="nvim"
alias vimdiff="nvim -d"
alias bat="bat --paging=never"
alias noise="play -n -q synth 2:0:0 brownnoise synth pinknoise mix synth sine amod 0 10 &"
alias ipython="ipython --no-autoindent --ipython-dir=$HOME/.config/ipython --profile=$USER"
alias en="source .venv/bin/activate"

py() {
  (
    source .venv/bin/activate
    nvim -c "autocmd VimEnter * lua vim.defer_fn(function()
      require('telescope.builtin').find_files()
    end, 50)"
  )
}

# Helping mac users...
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"

    [[ -s "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] &&
        . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
else
    alias open="xdg-open"
fi

# Some utils
eval "$(pyenv init -)"
eval "$(fzf --bash)"

# Adds `~/.local/bin` to $PATH
export PATH="$HOME/.local/bin:$PATH"
# vim-gnupg
export GPG_TTY=$(tty)
