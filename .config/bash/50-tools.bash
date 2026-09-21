# Tool Integrations
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS=" \
--color=bg:#101214,bg+:#181a1d,fg:#e6e8eb,fg+:#ffffff \
--color=hl:#f5b700,hl+:#ffd13b,info:#6e7681,marker:#f5b700 \
--color=prompt:#f5b700,spinner:#ffd13b,pointer:#f5b700,header:#6e7681 \
--color=border:#23272e \
--layout=reverse"
    eval "$(fzf --bash)"
fi
