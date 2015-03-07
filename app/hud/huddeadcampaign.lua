HudDeadCampaign = class()

local g = love.graphics

function HudDeadCampaign:init(hud)
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    deadOk = function()
      local u, v = hud.u, hud.v
      local w = u * .25
      local h = v * .1
      local x = u / 2 - w / 2
      local y = v - .05 * v - h
      return {x, y, w, h}
    end
  }

  self.deadAlpha = 0

  self.deadOk = hud.gooey:add(Button, 'hud.dead.ok')
  self.deadOk.geometry = function() return self.geometry.deadOk end
  self.deadOk:on('click', function() self:endGame() end)
  self.deadOk.text = 'Finished'

  self.delay = 3
  self.timeFactor = 0
  self.prevTimeFactor = self.timeFactor
  self.soundTimer = 0
  self.soundRate = 2 / ls.tickrate
  self.alpha = 0
  self.prevAlpha = self.alpha

  local function getMousePosition()
    return ctx.view:frameMouseX(), ctx.view:frameMouseY()
  end

  self.deadOk.getMousePosition = getMousePosition
end

function HudDeadCampaign:update()
  if not ctx.ded then return end
  self.deadAlpha = math.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * ls.tickrate)

  if ctx.backgroundSound:isPlaying() then
    ctx.backgroundSound:setVolume(math.max(ctx.backgroundSound:getVolume() - 2 * ls.tickrate, 0))
    if ctx.backgroundSound:getVolume() == 0 then
      ctx.backgroundSound:stop()
    end
  end

  self.delay = timer.rot(self.delay)
  if self.delay == 0 then
    self.prevAlpha = self.alpha
    self.alpha = math.lerp(self.alpha, 1, math.min(6 * ls.tickrate, 1))

    self.prevTimeFactor = self.timeFactor
    self.timeFactor = math.lerp(self.timeFactor, 1, 2 * ls.tickrate)

    self.soundTimer = timer.rot(self.soundTimer)
    if self.soundTimer == 0 and math.floor(ctx.timer * self.prevTimeFactor * ls.tickrate) ~= math.floor(ctx.timer * self.timeFactor * ls.tickrate) then
      ctx.sound:play('juju1', function(sound)
        sound:setPitch(.25 + self.timeFactor)
        sound:setVolume(self.timeFactor * .75)
      end)
      self.soundTimer = 1 / self.soundRate
    end
  end
end

function HudDeadCampaign:draw()
  if not ctx.ded then return end
  ctx.timer = 12 * 60 / ls.tickrate

  local u, v = ctx.hud.u, ctx.hud.v
  local bigFont = .09 * v
  local smallFont = .05 * v
  local timeFactor = math.lerp(self.prevTimeFactor, self.timeFactor, ls.accum / ls.tickrate)
  if self.timeFactor ~= 1 and math.round(ctx.timer * ls.tickrate) == math.round(ctx.timer * ls.tickrate * timeFactor) then
    self.timeFactor = 1
    timeFactor = 1
    ctx.sound:play('juju1', function(sound) sound:setPitch(2) end)
  end
  local alpha = math.lerp(self.prevAlpha, self.alpha, ls.accum / ls.tickrate)

  g.setColor(244, 188, 80, 255 * self.deadAlpha)
  g.setFont('mesmerize', bigFont)
  local str = 'Game Over!'
  g.printCenter(str, u * .5, v * .175)

  if timeFactor > 0 then
    g.setColor(253, 238, 65, 255 * alpha)
    g.setFont('mesmerize', smallFont)
    str = 'You Scored:'
    g.printCenter(str, u * .5, v * .3)

    g.setColor(240, 240, 240, 255 * alpha)
    str = tostring(toTime(ctx.timer * ls.tickrate * timeFactor, true))
    g.printCenter(str, u * .5, v * .375)
  end

  local inc = .2 * u
  local size = .15 * v
  local medalX = .5 * u - (inc * (3 - 1) / 2)
  for _, medal in ipairs({'bronze', 'silver', 'gold'}) do
    local image = data.media.graphics.menu[medal]
    local scale = size / image:getHeight()
    local alpha = alpha
    if ctx.timer * ls.tickrate * timeFactor < config.medals[medal] then alpha = alpha / 3 end
    g.setColor(255, 255, 255, 255 * alpha)
    g.draw(image, medalX, .5 * v, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    medalX = medalX + inc
  end

  self.deadOk:draw()
end

function HudDeadCampaign:keypressed(key)
  if not ctx.ded then return end

  if key == 'return' then self:endGame() end
end

function HudDeadCampaign:endGame()
  Context:add(Menu, ctx.user, ctx.options, {page = ctx.mode, biome = ctx.biome, user = ctx.user})
  Context:remove(ctx)
end
