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

# Quick dated scratchpad (`note`) or open/create named kebab-case note (`note my topic`)
# Leaves no file on disk if aborted/unchanged/empty.
note() {
    if [ $# -eq 0 ]; then
        local file
        file=$(zk new --no-input --print-path) || return 1
        local before_sum
        before_sum=$(cksum < "$file")
        nvim "$file"
        if [ ! -s "$file" ] || [ "$(cksum < "$file")" = "$before_sum" ]; then
            rm -f "$file"
        fi
    else
        local title="$*"
        local slug
        slug=$(printf '%s' "${title%.md}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
        local file="$ZK_NOTEBOOK_DIR/${slug}.md"
        if [ -f "$file" ]; then
            nvim "$file"
        else
            NOTE_INIT_TITLE="${title%.md}" nvim \
                -c 'lua vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. vim.env.NOTE_INIT_TITLE, "" }); vim.bo.modified = false; vim.api.nvim_win_set_cursor(0, { 2, 0 })' \
                "$file"
            [ -f "$file" ] && [ ! -s "$file" ] && rm -f "$file"
        fi
    fi
}

daily() {
    local today_file="$ZK_NOTEBOOK_DIR/daily/$(date +%Y-%m-%d).md"
    local existed=0
    [ -f "$today_file" ] && existed=1
    local file
    file=$(zk new --group daily --no-input --print-path) || return 1
    local before_sum
    before_sum=$(cksum < "$file")
    nvim "$file"
    if [ "$existed" -eq 0 ] && { [ ! -s "$file" ] || [ "$(cksum < "$file")" = "$before_sum" ]; }; then
        rm -f "$file"
    fi
}

ngrep() {
    rg --glob '!.zk/*' -- "$@" "$ZK_NOTEBOOK_DIR"
}

