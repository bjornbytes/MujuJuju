local g = love.graphics

HudWon = class()

function HudWon:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    continue = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local x = .5 * u
      local y = .5 * v
      local w = .3 * v
      local h = w / 1.6

      return {x - w / 2, y - h / 2, w, h}
    end
  }
end

function HudWon:update()
  
end

function HudWon:draw()
  if not ctx.won or ctx.hud.upgrades.active then return end

  local u, v = ctx.hud.u, ctx.hud.v

  local x, y, w, h = unpack(self.geometry.continue)
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', x, y, w, h)

  g.setFont('mesmerize', .06 * v)
  g.setColor(255, 255, 255)
  g.printCenter('Continue', x + w / 2, y + h / 2)
end

function HudWon:mousepressed(mx, my, b)
  if not ctx.won or ctx.hud.upgrades.active then return end

  if b == 'l' and math.inside(mx, my, unpack(self.geometry.continue)) then
    ctx:nextBiome()
  end
end
