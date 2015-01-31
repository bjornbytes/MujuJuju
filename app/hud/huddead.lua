HudDead = class()

local g = love.graphics

function HudDead:init()
  self.hub = 'http://96.126.101.55:7000/api/highscores'
  self.deadAlpha = 0

  self.deadOk = data.media.graphics.deathOk
  self.deadReplay = data.media.graphics.deathReplay
  self.deadQuit = data.media.graphics.deathQuit
  self.deadNameFrame = data.media.graphics.deathBox
  self.deadScreen = 1
  self.deadName = ''
end

function HudDead:update()
  if not ctx.ded then return end
  self.deadAlpha = math.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * tickRate)
end

function HudDead:draw()
  if not ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local bigFont = .09 * v
  local smallFont = .05 * v

  local deadOkScale = (.1575 * u) / self.deadOk:getWidth()
  local deadReplayScale = (.1575 * u) / self.deadQuit:getWidth()
  local deadQuitScale = (.1575 * u) / self.deadQuit:getWidth()
  local deadNameFrameScale = (.4 * u) / self.deadNameFrame:getWidth()

  if self.deadScreen == 1 then
    g.setColor(244, 188, 80, 255 * self.deadAlpha)
    g.setFont('mesmerize', bigFont)
    local str = 'YOUR SHRINE HAS BEEN DESTROYED!'
    g.printCenter(str, u * .5, v * .175)

    g.setColor(253, 238, 65, 255 * self.deadAlpha)
    g.setFont('mesmerize', smallFont)
    str = 'Your Score:'
    g.printCenter(str, u * .5, v * .375)

    g.setColor(240, 240, 240, 255 * self.deadAlpha)
    str = tostring(math.floor(ctx.timer))
    g.printCenter(str, u * .5, v * .45)

    g.setColor(253, 238, 65, 255 * self.deadAlpha)
    str = 'Your Name:'
    g.printCenter(str, u * .5, v * .525)

    local x =  u / 2 - (deadNameFrameScale * self.deadNameFrame:getWidth()) / 2
    local y =  v * .584
    g.setColor(255, 255, 255, 255 * self.deadAlpha)
    g.draw(self.deadNameFrame, x, y, 0, deadNameFrameScale, deadNameFrameScale)

    g.setColor(240, 240, 240, 255 * self.deadAlpha)
    local font = g.getFont()
    local scale = 1
    while font:getWidth(self.deadName) * scale > deadNameFrameScale * self.deadNameFrame:getWidth() - 24 do scale = scale - .05 end

    local xx = u / 2 - font:getWidth(self.deadName) * scale / 2
    local yy = v * .584 + (deadNameFrameScale * self.deadNameFrame:getHeight() / 2) - font:getHeight() * scale / 2
    g.print(self.deadName, xx, yy, 0, scale, scale)

    local cursorx = xx + font:getWidth(self.deadName) * scale + 1
    g.line(cursorx, yy, cursorx, yy + font:getHeight() * scale)

    local x = u / 2 - (deadOkScale * self.deadOk:getWidth()) / 2
    local y = v * .825
    g.setColor(255, 255, 255, 255 * self.deadAlpha)
    g.draw(self.deadOk, x, y, 0, deadOkScale, deadOkScale)
  else
    if self.highscores then
      g.setColor(253, 238, 65, 255 * self.deadAlpha)
      g.setFont('mesmerize', smallFont)
      g.printCenter('Highscores', u * .5, v * .07)

      g.setColor(255, 255, 255, 255 * self.deadAlpha)
      local yy = v * .149

      for _, entry in ipairs(self.highscores) do
        g.print(entry.country, u * .27, yy)
        g.print(entry.name, u * .325, yy)
        g.printf(entry.score, 0, yy, u * .725, 'right')
        yy = yy + g.getFont():getHeight() + 4
      end
    else
      g.setColor(253, 238, 65, 255 * self.deadAlpha)
      g.setFont('mesmerize', smallFont)
      g.printf('Unable to load highscores :[', 0, v * .4, u, 'center')
    end

    local x = u / 2 - (deadQuitScale * self.deadQuit:getWidth()) / 2
    local y = v * .825
    g.draw(self.deadQuit, x, y, 0, deadQuitScale, deadQuitScale)
  end
end

function HudDead:keypressed(key)
  if not ctx.ded then return end

  if self.deadScreen == 1 then
    if key == 'escape' then
      Context:remove(ctx)
      local biomeIndex = nil
      for i = 1, #config.biomeOrder do
        if config.biomeOrder[i] == ctx.biome then biomeIndex = i break end
      end
      Context:add(Menu, biomeIndex, {muted = ctx.sound.muted})
    elseif key == 'backspace' then
      self.deadName = self.deadName:sub(1, -2)
    elseif key == 'return' then
      self:sendScore()
    end
  elseif self.deadScreen == 2 then
    if key == 'return' then
      local biomeIndex = nil
      for i = 1, #config.biomeOrder do
        if config.biomeOrder[i] == ctx.biome then biomeIndex = i end
      end

      Context:add(Menu, biomeIndex, {muted = ctx.sound.muted})
      Context:remove(ctx)
    end
  end
end

function HudDead:mousereleased(x, y, b)
  if not ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v

  if self.deadScreen == 1 then
    local deadOkScale = (.1575 * u) / self.deadOk:getWidth()
    local xx = u / 2 - (deadOkScale * self.deadOk:getWidth()) / 2
    local yy = v * .825

    if b == 'l' and math.inside(x, y, xx, yy, xx + deadOkScale * self.deadOk:getWidth(), yy + deadOkScale * self.deadOk:getHeight()) then
      self:sendScore()
    end
  elseif self.deadScreen == 2 then
    local deadQuitScale = (.1575 * u) / self.deadQuit:getWidth()
    local xx = u / 2 - (deadQuitScale * self.deadQuit:getWidth()) / 2
    local yy = v * .825

    if b == 'l' then
      if math.inside(x, y, xx, yy, xx + deadQuitScale * self.deadQuit:getWidth(), yy + deadQuitScale * self.deadQuit:getHeight()) then
        local biomeIndex = nil
        for i = 1, #config.biomeOrder do
          if config.biomeOrder[i] == ctx.biome then biomeIndex = i end
        end

        Context:add(Menu, biomeIndex, {muted = ctx.sound.muted})
        Context:remove(ctx)
      end
    end
  end
end

function HudDead:textinput(char)
  if ctx.ded then
    if #self.deadName < 12 and char:match('%w') then
      self.deadName = self.deadName .. char
    end
  end
end

function HudDead:sendScore()
  self.highscores = nil

  if #self.deadName > 0 then
    local http = require('socket.http')
    local payload = 'name=' .. self.deadName .. '&score=' .. math.floor(ctx.timer) .. '&biome=' .. ctx.biome
    local response = http.request(self.hub, payload)

    if response then
      self.highscores = require('lib/deps/dkjson').decode(response)
    end

    self.deadScreen = 2
  end
end
