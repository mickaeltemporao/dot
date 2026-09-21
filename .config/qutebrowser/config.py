import medallion
config.load_autoconfig()

medallion.apply(c)

c.auto_save.session = True
c.content.autoplay = False
c.downloads.location.directory = "/tmp/"
c.fonts.hints = 'bold 12pt "Input Sans"'
c.fonts.keyhint = '12pt "Input Sans"'
c.fonts.statusbar = '10pt "Input Sans"'
c.fonts.tabs.selected = '11pt "Input Sans"'
c.fonts.tabs.unselected = '10pt "Input Sans"'
c.fonts.web.family.fixed = '"Input Mono"'
c.fonts.web.family.standard = '"Input Sans"'
c.new_instance_open_target = 'tab-silent'
c.new_instance_open_target_window = 'last-focused'
c.tabs.background = True
c.tabs.favicons.scale = 1.15
c.tabs.title.alignment = 'center'
c.tabs.title.format = '{current_title}'
c.window.hide_decoration = True
c.window.title_format = '{perc}{current_title}'

