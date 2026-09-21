def apply(c, options=None):
    if options is None:
        options = {}

    # NY Taxi (Medallion Dark) Palette
    bg = '#101214'
    bg_alt = '#181a1d'
    fg = '#e6e8eb'
    muted = '#6e7681'
    yellow = '#f5b700'
    yellow_bright = '#ffd13b'
    red = '#e06c75'
    green = '#98c379'
    border = '#23272e'

    # Completion
    c.colors.completion.category.bg = bg
    c.colors.completion.category.fg = yellow
    c.colors.completion.category.border.bottom = bg
    c.colors.completion.category.border.top = bg
    c.colors.completion.even.bg = bg
    c.colors.completion.odd.bg = bg_alt
    c.colors.completion.fg = fg
    c.colors.completion.item.selected.bg = yellow
    c.colors.completion.item.selected.fg = bg
    c.colors.completion.item.selected.border.bottom = yellow
    c.colors.completion.item.selected.border.top = yellow
    c.colors.completion.match.fg = yellow_bright

    # Statusbar
    c.colors.statusbar.normal.bg = bg
    c.colors.statusbar.normal.fg = fg
    c.colors.statusbar.insert.bg = yellow
    c.colors.statusbar.insert.fg = bg
    c.colors.statusbar.command.bg = bg_alt
    c.colors.statusbar.command.fg = fg
    c.colors.statusbar.url.fg = fg
    c.colors.statusbar.url.success.http.fg = green
    c.colors.statusbar.url.success.https.fg = green
    c.colors.statusbar.url.warn.fg = yellow

    # Tabs
    c.colors.tabs.bar.bg = bg
    c.colors.tabs.odd.bg = bg
    c.colors.tabs.odd.fg = muted
    c.colors.tabs.even.bg = bg
    c.colors.tabs.even.fg = muted
    c.colors.tabs.selected.odd.bg = yellow
    c.colors.tabs.selected.odd.fg = bg
    c.colors.tabs.selected.even.bg = yellow
    c.colors.tabs.selected.even.fg = bg

    # Hints
    c.colors.hints.bg = yellow
    c.colors.hints.fg = bg
    c.colors.hints.match.fg = bg_alt

    # Messages
    c.colors.messages.error.bg = red
    c.colors.messages.error.fg = '#ffffff'
    c.colors.messages.warning.bg = yellow
    c.colors.messages.warning.fg = bg
