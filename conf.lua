function love.conf(t)
	t.title = 'Muju Juju'
	t.console = false
	t.window.width = 800
	t.window.height = 600
	if arg[2] ~= 'local' then
		t.window.fullscreen = true
	end
end
