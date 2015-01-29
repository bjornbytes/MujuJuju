function love.run()
	if love.math then love.math.setRandomSeed(os.time(), os.time() % 19) end
	love.math.random() love.math.random()

	tickRate = .02
	tickDelta = 0

	love.load(arg)

	delta = 0

	while true do
		love.timer.step()
		delta = love.timer.getDelta()

		tickDelta = tickDelta + delta
		while tickDelta >= tickRate do
			tickDelta = tickDelta - tickRate

			love.event.pump()
			for e, a, b, c, d in love.event.poll() do
				if e == 'quit' then f.exe(love.quit) love.audio.stop() return
				else love.handlers[e](a, b, c, d) end
			end

			love.update()
		end

		love.graphics.clear()
		love.draw()
		love.graphics.present()
	end
end
