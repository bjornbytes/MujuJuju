HudDeadSurvival = class()

local g = love.graphics

function HudDeadSurvival:init(hud)
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    deadOk = function()
      local u, v = hud.u, hud.v
      local w = u * .25
      local h = v * .1
      local x = u / 2 - w / 2
      local y = v * .625
      return {x, y, w, h}
    end,
    deadQuit = function()
      local u, v = hud.u, hud.v
      local w = u * .25
      local h = v * .1
      local x = u / 2 - w / 2
      local y = v * .825
      return {x, y, w, h}
    end
  }

  self.hub = 'http://96.126.101.55:7000/api/highscores'
  self.deadAlpha = 0

  self.deadOk = hud.gooey:add(Button, 'hud.dead.ok')
  self.deadOk.geometry = function() return self.geometry.deadOk end
  self.deadOk:on('click', function()
    if ctx.options.offline then self:endGame()
    else self:sendScore() end
  end)
  self.deadOk.text = ctx.options.offline and 'Finished' or 'Next'

  self.deadQuit = hud.gooey:add(Button, 'hud.dead.quit')
  self.deadQuit.geometry = function() return self.geometry.deadQuit end
  self.deadQuit:on('click', function() self:endGame() end)
  self.deadQuit.text = 'Finished'

  local function getMousePosition()
    return ctx.view:frameMouseX(), ctx.view:frameMouseY()
  end

  self.deadOk.getMousePosition, self.deadQuit.getMousePosition = getMousePosition, getMousePosition

  self.deadScreen = 1
end

function HudDeadSurvival:update()
  if not ctx.ded then return end
  self.deadAlpha = lume.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * ls.tickrate)
end

function HudDeadSurvival:draw()
  if not ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local bigFont = .09 * v
  local smallFont = .05 * v

  if self.deadScreen == 1 then
    g.setColor(244, 188, 80, 255 * self.deadAlpha)
    g.setFont('mesmerize', bigFont)
    local str = 'YOUR SHRINE HAS BEEN DESTROYED!'
    g.printCenter(str, u * .5, v * .175)

    g.setColor(253, 238, 65, 255 * self.deadAlpha)
    g.setFont('mesmerize', smallFont)
    str = 'You Scored:'
    g.printShadow(str, u * .5, v * .375, true)

    g.setColor(240, 240, 240, 255 * self.deadAlpha)
    str = tostring(toTime(ctx.timer * ls.tickrate, true))
    g.printCenter(str, u * .5, v * .45)

    self.deadOk:draw()
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
        g.printf(toTime(tonumber(entry.score) * ls.tickrate, true), 0, yy, u * .725, 'right')
        yy = yy + g.getFont():getHeight() + 4
      end
    else
      g.setColor(253, 238, 65, 255 * self.deadAlpha)
      g.setFont('mesmerize', smallFont)
      g.printf('Unable to load highscores :(', 0, v * .4, u, 'center')
    end

    self.deadQuit:draw()
  end
end

function HudDeadSurvival:keypressed(key)
  if not ctx.ded then return end

  if self.deadScreen == 1 and key == 'return' then
    self:sendScore()
  elseif self.deadScreen == 2 and key == 'return' then
    self:endGame()
  end
end

function HudDeadSurvival:mousemoved(mx, my)

end

function HudDeadSurvival:endGame()
  Context:add(Menu, ctx.user, ctx.options, {page = ctx.mode, biome = ctx.biome, user = ctx.user})
  Context:remove(ctx)
end

function HudDeadSurvival:sendScore()
  self.highscores = nil

  local http = require('socket.http')
  local payload = 'name=' .. ctx.user.name .. '&score=' .. math.floor(ctx.timer)
  local response = http.request(self.hub, payload)

  if response then
    self.highscores = require('lib/deps/dkjson').decode(response)
  end

  self.deadScreen = 2
end
