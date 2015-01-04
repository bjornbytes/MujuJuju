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
      if not ctx.hud.tooltip then
        local shruju = p.shrujus[i]
        local str = '{title}' .. (shruju.effect and '{purple}' or '{white}') .. shruju.name .. '{normal}\n'
        str = str .. '{whoCares}' .. shruju.description .. '{white}\n'
        if shruju.effect then str = str .. '{purple}' .. shruju.effect.description end
        ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
        ctx.hud.tooltipRaw = str:gsub('{%a+}', '')
      end
      ctx.hud.tooltipHover = true
    end
  end
end

function HudShruju:draw()
  do return end
  local p = ctx.players:get(ctx.id)
  local shruju = self.geometry.shruju
  for i = 1, #shruju do
    local x, y, r = unpack(self.geometry.shruju[i])

    g.setColor(0, 0, 0, 200)
    g.circle('fill', x, y, r)

    if p.shrujus[i] then
      g.setColor(p.shrujus[i].effect and {100, 0, 200} or {255, 255, 255})
      g.circle('line', x, y, r)
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
      table.remove(p.shrujus, i)
    end
  end
end
