function love.conf(t)
  t.identity = 'muju'
  t.version = '0.9.1'
	t.console = false

	t.window.title = 'Muju Juju'
  t.window.icon = 'media/graphics/icon.png'
	t.window.width = 800 --1067
	t.window.height = 600 --600
  t.window.minwidth = 400
  t.window.minheight = 250
  t.window.fullscreen = true
  t.window.fullscreentype = 'desktop'
  t.window.vsync = false
  t.window.fsaa = 4
  t.window.highdpi = true
end
