local tween = require 'lib/deps/tween/tween'
local rich = require 'lib/deps/richtext/richtext'
local g = love.graphics

HudShrujuPatch = class()

function HudShrujuPatch:init(patch)
  self.patch = patch
  self.active = false
  self.lastPress = 0
  self.time = 0
  self.prevTime = self.time
  self.maxTime = .45
  self.factor = {value = 0}
  self.tween = tween.new(self.maxTime, self.factor, {value = 1}, 'inOutBack')
  self.growingFactor = 0
  self.prevGrowingFactor = self.growingFactor

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    types = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local ct = #self.patch.types
      local factor, t = self:getFactor()
      local growingFactor = math.lerp(self.prevGrowingFactor, self.growingFactor, tickDelta / tickRate)
      local length = .35 * v * factor + (.1 * growingFactor * v)
      local angleIncrement = .28
      local angle = (-math.pi / 2) - (angleIncrement * (ct - 1) / 2)

      local size = v * .08
      local res = {}
      for i = 1, ct do
        local x = self.patch.x + math.dx(length, angle) - size / 2
        local y = self.patch.y + math.dy(length, angle) - size / 2
        local w, h = size, size

        table.insert(res, {x, y, w, h})
        angle = angle + angleIncrement
      end
      return res
    end,

    slot = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local size = v * .1
      return {self.patch.x - size / 2, self.patch.y - .35 * v, size, size}
    end
  }
end

function HudShrujuPatch:update()
  if not self.patch then return end
  local p = ctx.players:get(ctx.id)
  local mx, my = love.mouse.getPosition()

  if not self:playerNearby() then
    self.active = false
  end

  if self.active then
    local types = self.geometry.types
    for i = 1, #types do
      local shruju = data.shruju[self.patch.types[i]]
      local x, y, w, h = unpack(types[i])
      -- Tooltip
      if math.inside(mx, my, x, y, w, h) then
        local str = '{title}{white}'  .. shruju.name .. '{normal}\n'
        str = str .. '{whoCares}' .. shruju.description
        local raw = str:gsub('{%a+}', '')
        if not ctx.hud.tooltip or ctx.hud.tooltipRaw ~= raw then
          ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
          ctx.hud.tooltipRaw = raw
        end
        ctx.hud.tooltipHover = true
      end
    end
  end

  if (self.patch.growing or self.patch.slot) and math.inside(mx, my, unpack(self.geometry.slot)) then
    local shruju = data.shruju[self.patch.growing] or self.patch.slot
    local str = '{title}{white}'  .. shruju.name .. '{normal}\n'
    str = str .. '{whoCares}' .. shruju.description
    local raw = str:gsub('{%a+}', '')
    if not ctx.hud.tooltip or ctx.hud.tooltipRaw ~= raw then
      ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
      ctx.hud.tooltipRaw = raw
    end
    ctx.hud.tooltipHover = true
  end

  self.prevTime = self.time
  if self.active then self.time = math.min(self.time + tickRate, self.maxTime)
  else self.time = math.max(self.time - tickRate, 0) end

  self.prevGrowingFactor = self.growingFactor
  self.growingFactor = math.lerp(self.growingFactor, (self.patch.growing or self.patch.slot) and 1 or 0, math.min(8 * tickRate, 1))
end

function HudShrujuPatch:draw()
  local u, v = ctx.hud.u, ctx.hud.v

  if self.patch then
    g.setFont('pixel', 8)

    local factor, t = self:getFactor()
    local alphaFactor = (t / self.maxTime) ^ 4

    if t < 1 or (self.growingFactor > .01 and self.growingFactor < .99) then table.clear(self.geometry)
    elseif t == 0 then return end

    local types = self.geometry.types

    for i = 1, #types do
      local shruju = data.shruju[self.patch.types[i]]
      local x, y, w, h = unpack(types[i])

      g.setColor(255, 255, 255, alphaFactor * 200)
      local image = data.media.graphics.hud.frame
      local scale = w / 125
      local xx, yy = x - 60 * scale, y - 60 * scale
      g.draw(image, xx, yy, 0, scale, scale)

      local image = data.media.graphics.shruju[self.patch.types[i]]
      local scale = (h - .02 * v) / image:getHeight()
      g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      local image = data.media.graphics.hud.title
      local scale = (w + 5) / 125
      g.draw(image, x + (w / 2), y + (120 * scale), 0, scale, scale, image:getWidth() / 2)

      g.setFont('mesmerize', image:getHeight() * scale - 7)
      g.printCenter(shruju.name, x + (image:getWidth() * (w / 125)) / 2, y + (120 * scale) + (image:getHeight() * scale) / 2)
    end

    if self.patch.growing or self.patch.slot then
      g.setColor(255, 255, 255, self.patch.slot and 200 or 120)

      local code = self.patch.growing or self.patch.slot.code

      local x, y, w, h = unpack(self.geometry.slot)
      local image = data.media.graphics.hud.frame
      local scale = w / 125
      local xx, yy = x - 60 * scale, y - 60 * scale
      g.draw(image, xx, yy, 0, scale, scale)

      local image = data.media.graphics.shruju[code]
      local scale = (h - .02 * v) / image:getHeight()
      g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      local image = data.media.graphics.hud.title
      local scale = (w + 5) / 125
      g.setColor(255, 255, 255, 80)
      g.draw(image, x - (scale - (w / 125)) * image:getWidth() / 2, y + (120 * scale), 0, scale, scale)

      g.setColor(255, 255, 255)
      g.draw(image, x - (scale - (w / 125)) * image:getWidth() / 2, y + (120 * scale), 0, scale * (1 - (self.patch.timer / 60)), scale)

      g.setFont('mesmerize', image:getHeight() * scale - 7)
      g.printCenter(data.shruju[code].name, x + (image:getWidth() * (w / 125)) / 2, y + (120 * scale) + (image:getHeight() * scale) / 2)
    end
  end
end

function HudShrujuPatch:keypressed(key)
  if self.patch and key == 'tab' or key == 'e' then
    self.lastPress = tick
    self.active = not self.active
    if not self:playerNearby() then self.active = false end
  end
end

function HudShrujuPatch:keyreleased(key)
  if self.patch and key == 'tab' or key == 'e' then
    if (tick - self.lastPress) * tickRate > self.maxTime then
      self.active = false
    end
  end
end

function HudShrujuPatch:mousepressed(x, y, b)
  if not self.patch or not self.active or self.patch.timer > 0 then return end

  local p = ctx.players:get(ctx.id)

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
      shruju:eat()
    elseif b == 'l' and #p.shrujus < 3 then
      local shruju = self.patch:take()
      table.insert(p.shrujus, shruju)
      if shruju.effect then shruju.effect:pickup(shruju) end
    end
  end
end

function HudShrujuPatch:playerNearby()
  return self.patch and self.patch:playerNearby()
end

function HudShrujuPatch:getFactor()
  local t = math.lerp(self.prevTime, self.time, tickDelta / tickRate)
  self.tween:set(t)
  return self.factor.value, t
end
