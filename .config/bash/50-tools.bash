# Tool Integrations
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi
