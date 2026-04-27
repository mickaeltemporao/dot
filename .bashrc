# PROMPT_COMMAND="PS1_CMD1=$(git branch --show-current 2>/dev/null)"; PS1="\[\e[38;5;125;1m\]\u\[\e[0m\]@\[\e[38;5;31m\]\h\[\e[0m\] \[\e[38;5;119;1m\]\w\[\e[0m\] \[\e[38;5;199;53m\]${PS1_CMD1}\n\[\e[0m\]\$ "

# if [ -f ~/.local/bin/sensible.bash ]; then
#    source ~/.local/bin/sensible.bash
# fi

alias dot="/usr/bin/git --git-dir=$HOME/.dot/ --work-tree=$HOME"
alias ls="ls -lah --color=auto"
alias grep="grep --color=auto"
alias vi="nvim"
alias vim="nvim"
alias vimdiff="nvim -d"
alias cat=bat
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

# Check if Homebrew exists
if [ -x "/opt/homebrew/bin/brew" ]; then
    # Homebrew is installed → set up shell environment
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    # Homebrew not found → set alias for open
    alias open="xdg-open"
fi

if [[ -s $HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh ]]; then
  . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

eval "$(pyenv init -)"
eval "$(fzf --bash)"

# Adds `~/.local/bin` to $PATH
export PATH="$HOME/.local/bin:$PATH"

# vim-gnupg
export GPG_TTY=$(tty)
