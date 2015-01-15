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
      local y = .4 * v
      local w = .35 * v
      local h = .1 * v

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
  g.setColor(255, 255, 255)
  ctx.hud.button:draw('Continue', x, y, w, h)
end

function HudWon:mousepressed(mx, my, b)
  if not ctx.won or ctx.hud.upgrades.active then return end

  if b == 'l' and math.inside(mx, my, unpack(self.geometry.continue)) then
    ctx:nextBiome()
  end
end
