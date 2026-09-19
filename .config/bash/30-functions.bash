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
