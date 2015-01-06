local rich = require 'lib/deps/richtext/richtext'
local g = love.graphics

HudShruju = class()

function HudShruju:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    shruju = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local p = ctx.players:get(ctx.id)
      local size = .08 * v
      local inc = (size * 2) + .02 * v
      local x = u * .5 - (inc * (#p.magicShruju - 1) / 2)
      local y = v - (size / 2) - .02 * v
      local res = {}
      for i = 1, #p.magicShruju do
        table.insert(res, {x - size / 2, y - size / 2, size, size})
        x = x + inc
      end
      return res
    end
  }
end

function HudShruju:update()
  local shruju = self.geometry.shruju
  local mx, my = love.mouse.getPosition()
  local p = ctx.players:get(ctx.id)
  for i = 1, #shruju do
    local x, y, w, h = unpack(self.geometry.shruju[i])
    if math.inside(mx, my, x, y, w, h) then
      ctx.hud.tooltip:setMagicShrujuTooltip(p.magicShruju[i])
    end

    if love.math.random() < 4 * tickRate then
      ctx.particles:emit('magicshruju', x + w / 2, y + h / 2, 1)
    end
  end

  if #p.magicShruju ~= self.geometry.shruju then
    self.geometry.shruju = nil
  end
end

function HudShruju:draw()
  local p = ctx.players:get(ctx.id)
  local shruju = self.geometry.shruju
  local u, v = ctx.hud.u, ctx.hud.v
  for i = 1, #shruju do
    local x, y, w, h = unpack(self.geometry.shruju[i])

    local image = data.media.graphics.hud.frame
    local scale = w / 125
    g.setColor(255, 255, 255, 220)
    g.draw(image, x, y, 0, scale, scale)

    local image = data.media.graphics.shruju[p.magicShruju[i].code]
    local scale = (w - (.02 * v)) / (image:getHeight() - 8)
    g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  end
end
