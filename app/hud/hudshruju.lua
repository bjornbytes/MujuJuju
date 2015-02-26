local g = love.graphics

HudShruju = class()

function HudShruju:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    shruju = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local size = .08 * v
      local x = u * .5
      local y = v - (size / 2) - .01 * v
      return {x - size / 2, y - size / 2, size, size}
    end
  }
end

function HudShruju:update()
  local mx, my = love.mouse.getPosition()
  local p = ctx.player

  if p.shruju and love.math.random() < 4 * ls.tickrate then
    local x, y, w, h = unpack(self.geometry.shruju)
    ctx.particles:emit('magicshruju', x + w / 2, y + h / 2, 1)
  end
end

function HudShruju:draw()
  if #self.geometry.shruju == 0 then return end

  local atlas = data.atlas.hud
  local p = ctx.player
  local shruju = self.geometry.shruju
  local u, v = ctx.hud.u, ctx.hud.v
  if p.shruju then
    local x, y, w, h = unpack(self.geometry.shruju)

    local scale = w / 125
    g.setColor(255, 255, 255, 220)
    g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)

    local image = data.media.graphics.shruju['harvest']
    local scale = math.min((w - (.02 * v)) / (image:getHeight() - 8), (h - (.02 * v)) / (image:getWidth() - 8))
    g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  end
end

function HudShruju:mousemoved(mx, my)
  local p = ctx.player
  local shruju = self.geometry.shruju
  if p.shruju then
    local x, y, w, h = unpack(shruju)
    if math.inside(mx, my, x, y, w, h) then
      ctx.hud.tooltip:setMagicShrujuTooltip(p.shruju)
      return
    end
  end
end
