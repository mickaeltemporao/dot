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

# Medallion Dark (NYC Taxi) LS_COLORS
# Directories: Bold Yellow (01;33) | Symlinks: Cyan (01;36) | Executables: Green (01;32)
# Archives: Red (01;31) | Images/Media: Magenta (01;35) | Documents: Amber (00;33)
export LS_COLORS="rs=0:di=01;33:ln=01;36:mh=00:pi=33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;31:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.zst=01;31:*.gz=01;31:*.bz2=01;31:*.xz=01;31:*.7z=01;31:*.rar=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.jpeg=01;35:*.png=01;35:*.gif=01;35:*.svg=01;35:*.webp=01;35:*.mp4=01;35:*.mkv=01;35:*.webm=01;35:*.mp3=00;36:*.flac=00;36:*.wav=00;36:*.pdf=00;33:*.epub=00;33"
