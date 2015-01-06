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
      local radius = .04 * v
      local inc = (radius * 2) + .02 * v
      local x = u * .5 - (inc * (3 - 1) / 2)
      local y = v - radius - .02 * v
      local res = {}
      for i = 1, 3 do
        table.insert(res, {x, y, radius})
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
    local x, y, r = unpack(self.geometry.shruju[i])
    if p.shrujus[i] and math.insideCircle(mx, my, x, y, r) then
      local str = self.patch:makeTooltip(p.shrujus[i])
      local raw = str:gsub('{%a+}', '')
      if not ctx.hud.tooltip or ctx.hud.tooltipRaw ~= raw then
        ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
        ctx.hud.tooltipRaw = raw
      end
      ctx.hud.tooltipHover = true
    end
  end
end

function HudShruju:draw()
  local p = ctx.players:get(ctx.id)
  local shruju = self.geometry.shruju
  local u, v = ctx.hud.u, ctx.hud.v
  for i = 1, #shruju do
    local x, y, r = unpack(self.geometry.shruju[i])

    local image = data.media.graphics.hud.frame
    local scale = (2 * r) / 125
    g.setColor(255, 255, 255, p.shrujus[i] and 220 or 150)
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if p.shrujus[i] then
      local image = data.media.graphics.shruju[p.shrujus[i].code]
      local scale = (2 * r - (.02 * v)) / (image:getHeight() - 8)
      g.draw(image, x, y, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  end
end

function HudShruju:mousepressed(mx, my, b)
  local p = ctx.players:get(ctx.id)
  local shruju = self.geometry.shruju
  for i = 1, #shruju do
    local x, y, r = unpack(self.geometry.shruju[i])

    if math.insideCircle(mx, my, x, y, r) and p.shrujus[i] then
      p.shrujus[i]:eat()
      if p.shrujus[i].effect then p.shrujus[i].effect:drop(p.shrujus[i]) end
      p.shrujus[i] = nil
    end
  end
end
