# Shell Functions and Workflow Helpers
py() {
    (
        if [ -f .venv/bin/activate ]; then
            # shellcheck source=/dev/null
            source .venv/bin/activate
        fi
        nvim -c "autocmd VimEnter * lua vim.defer_fn(function()
            require('telescope.builtin').find_files()
        end, 50)"
    )
}

# Presentation mode: mirror eDP-1 (2560x1440) to connected external display
pres() {
    if [[ "${1:-}" == "off" ]]; then
        local targets
        targets="$(xrandr | awk '(!/eDP-1/) && (/ connected/ || / disconnected [0-9]/) {print $1}')"
        if [[ -n "$targets" ]]; then
            while IFS= read -r out; do
                [[ -n "$out" ]] && xrandr --output "$out" --off
            done <<< "$targets"
            echo "pres: disabled external display(s)"
        else
            echo "pres: no active external display to disable"
        fi
        xwallpaper --output all --zoom "$HOME/.local/share/wallpaper/wallpaper.jpg" 2>/dev/null || true
        return 0
    fi

    local ext
    ext="$(xrandr | awk '/ connected/ && !/eDP-1/ {print $1; exit}')"

    if [[ -z "$ext" ]]; then
        echo "pres: no external display connected" >&2
        return 1
    fi

    echo "pres: mirroring eDP-1 (2560x1440) to $ext..."
    xrandr --output "$ext" --auto --same-as eDP-1 --scale-from 2560x1440
    xwallpaper --output all --zoom "$HOME/.local/share/wallpaper/wallpaper.jpg" 2>/dev/null || true
}

