local g = love.graphics

HudShrujuPatch = class()

function HudShrujuPatch:init(patch)
  self.patch = patch
  self.active = false

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    types = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local ct = #self.patch.types
      local size = v * .1
      local inc = size + v * .01
      local xx = self.patch.x - inc * ((ct - 1) / 2)
      local res = {}
      for i = 1, ct do
        local x, y, w, h = xx - size / 2, self.patch.y - self.patch.height - size * 2, size, size
        table.insert(res, {x, y, w, h})
        xx = xx + inc
      end
      return res
    end,

    slot = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local size = v * .1
      return {self.patch.x - size / 2, self.patch.y - self.patch.height - size * 2 - size - v * .01, size, size}
    end
  }
end

function HudShrujuPatch:update()
  if not self.patch then return end
  local p = ctx.players:get(ctx.id)
  if not self:playerNearby() then
    self.active = false
  end
end

function HudShrujuPatch:draw()
  if self.active and self.patch then
    local types = self.geometry.types
    g.setFont('pixel', 8)
    for i = 1, #types do
      local str = self.patch.types[i]
      local x, y, w, h = unpack(types[i])
      g.setColor(0, 0, 0)
      g.rectangle('fill', x, y, w, h)
      g.setColor(255, 255, 255)
      if not self.patch.growing and not self.patch.slot then
        g.rectangle('line', x + .5, y + .5, w, h)
      end
      g.print(str, x + w / 2 - g.getFont():getWidth(self.patch.types[i]) / 2, y + 2)
    end

    g.setColor(0, 0, 0)
    local x, y, w, h = unpack(self.geometry.slot)
    g.rectangle('fill', x, y, w, h)

    g.setColor(255, 255, 255)
    local str = self.patch.slot or 'empty'
    g.print(str, x + w / 2 - g.getFont():getWidth(str) / 2, y + 2)
    if self.patch.slot then
      g.rectangle('line', x + .5, y + .5, w, h)
      local str = 'lmb to take, rmb to eat'
      g.print(str, x + w / 2 - g.getFont():getWidth(str) / 2, y - 2 - g.getFont():getHeight())
    end
  end
end

function HudShrujuPatch:keypressed(key)
  if self.patch and key == 'e' and self:playerNearby() then
    self.active = not self.active
  end
end

function HudShrujuPatch:mousepressed(x, y, b)
  if not self.patch or not self.active or self.patch.timer > 0 then return end

  if b == 'l' then
    local types = self.geometry.types
    for i = 1, #types do
      if math.inside(x, y, unpack(types[i])) then
        self.patch:grow(self.patch.types[i])
      end
    end
  end

  if self.patch.slot and math.inside(x, y, unpack(self.geometry.slot)) then
    if b == 'r' then
      local shruju = self.patch:take()
      Shrujus[shruju].eat()
    elseif b == 'l' then
      -- put in inventory
    end
  end
end

function HudShrujuPatch:playerNearby()
  return self.patch and self.patch:playerNearby()
end
