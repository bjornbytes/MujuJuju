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

  local function getMousePosition()
    return ctx.view:frameMouseX(), ctx.view:frameMouseY()
  end

  self.deadOk.getMousePosition = getMousePosition
end

function HudDeadCampaign:update()
  if not ctx.ded then return end
  self.deadAlpha = math.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * ls.tickrate)
end

function HudDeadCampaign:draw()
  if not ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local bigFont = .09 * v
  local smallFont = .05 * v

  g.setColor(244, 188, 80, 255 * self.deadAlpha)
  g.setFont('mesmerize', bigFont)
  local str = 'YOUR SHRINE HAS BEEN DESTROYED!'
  g.printCenter(str, u * .5, v * .175)

  g.setColor(253, 238, 65, 255 * self.deadAlpha)
  g.setFont('mesmerize', smallFont)
  str = 'You Scored:'
  g.printCenter(str, u * .5, v * .375)

  g.setColor(240, 240, 240, 255 * self.deadAlpha)
  str = tostring(toTime(ctx.timer * ls.tickrate, true))
  g.printCenter(str, u * .5, v * .45)

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
