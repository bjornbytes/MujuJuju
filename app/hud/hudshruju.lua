local g = love.graphics

HudShruju = class()

function HudShruju:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    shruju = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local size = .075 * v
      local x = u * .5
      local y = v - (size / 2) - .005 * v
      return {x - size / 2, y - size / 2, size, size}
    end
  }
end

function HudShruju:update()
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

    local image = data.media.graphics.shruju['shruju' .. p.shruju.index]
    local scale = math.min((w - (.02 * v)) / (image:getHeight() - 8), (h - (.02 * v)) / (image:getWidth() - 8))
    g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    local str = p.shruju.name
    local font = g.setFont('mesmerize', .02 * v)
    local qw, qh = atlas:getDimensions('title')
    local padding = .01 * v
    local xscale = (font:getWidth(str) + 2 * padding) / qw
    local yscale = (font:getHeight() + 2 * padding) / qh
    y = y - h / 2 - .005 * v - qh * yscale * .5
    g.setColor(255, 255, 255, 100)
    g.draw(atlas.texture, atlas.quads.title, x + w / 2, y + h / 2, 0, xscale, yscale, qw / 2, qh / 2)
    g.setColor(255, 255, 255, 200)
    g.printShadow(str, x + w / 2, y + h / 2, true)
  end

  ctx.shrujus:each(function(shruju)
    local str = shruju.name
    local font = g.setFont('mesmerize', .02 * v)
    local x, y = ctx.view:screenPoint(shruju.x, shruju.y)
    local w, h = atlas:getDimensions('title')
    local padding = .01 * v
    local xscale = (font:getWidth(str) + 2 * padding) / w
    local yscale = (font:getHeight() + 2 * padding) / h
    x = math.clamp(x, xscale * w / 2, u - xscale * w / 2)
    y = y + .08 * v
    g.setColor(255, 255, 255, 100)
    g.draw(atlas.texture, atlas.quads.title, x, y + .002 * v, 0, xscale, yscale, w / 2, h / 2)
    g.setColor(255, 255, 255, 200)
    g.printShadow(str, x, y, true)

    g.printShadow('Q', x, y + padding + g.getFont():getHeight(), true)
  end)
end

function HudShruju:mousemoved(mx, my)
  if ctx.ded then return end

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
