# Core System and Workflow Aliases
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
alias nm="neomutt"
if [[ "$OSTYPE" == "darwin"* ]] || command -v brew >/dev/null 2>&1; then
    alias open="open"
else
    alias open="xdg-open"
fi
