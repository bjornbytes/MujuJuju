function love.run()
  if love.math then love.math.setRandomSeed(os.time(), os.time() % 19) end
  love.math.random() love.math.random()

  tickRate = .03
  tickDelta = 0

  love.load(arg)

  delta = 0
  local framerateCap = 60
  local lastFrame = 0

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

    while love.timer.getTime() - lastFrame < (1 / framerateCap) do
      love.timer.sleep(.001)
    end

    lastFrame = love.timer.getTime()
    love.graphics.clear()
    love.draw()
    love.graphics.present()

    love.timer.sleep(.001)
  end
end
