# ~/.bashrc - Interactive Bash Configuration Loader
# Individual modules managed under ~/.config/bash/

# Non-interactive shells exit early
[[ $- != *i* ]] && return

# Source modular components in alphabetical/numerical order
if [ -d "$HOME/.config/bash" ]; then
    for _mod in "$HOME/.config/bash"/*.bash; do
        if [ -r "$_mod" ]; then
            # shellcheck source=/dev/null
            source "$_mod"
        fi
    done
    unset _mod
fi
