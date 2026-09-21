import medallion
config.load_autoconfig()

medallion.apply(c)

c.auto_save.session = True
c.content.autoplay = False
c.downloads.location.directory = "/tmp/"
c.fonts.hints = 'bold 14pt monospace'
c.fonts.keyhint = '14pt monospace'
c.fonts.statusbar = '10pt monospace'
c.fonts.tabs.selected = '12pt monospace'
c.fonts.tabs.unselected = '10pt monospace'
c.new_instance_open_target = 'tab-silent'
c.new_instance_open_target_window = 'last-focused'
c.tabs.background = True
c.tabs.favicons.scale = 1.15
c.tabs.title.alignment = 'center'
c.tabs.title.format = '{current_title}'
c.window.hide_decoration = True
c.window.title_format = '{perc}{current_title}'

