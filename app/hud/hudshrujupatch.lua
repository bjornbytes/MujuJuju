local tween = require 'lib/deps/tween/tween'
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
  self.slotScale = 1
  self.prevSlotScale = self.slotScale

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    slots = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local ct = #self.patch.slots
      local factor, t = self:getFactor()
      local length = (.1 + (.3 * factor)) * v
      local angleIncrement = .35
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
      local size = v * .08
      local growingFactor = math.lerp(self.prevGrowingFactor, self.growingFactor, tickDelta / tickRate)
      return {self.patch.x - size / 2, math.lerp(self.patch.y, v - size - .04 * v, growingFactor), size, size}
    end
  }
end

function HudShrujuPatch:update()
  if not self.patch then return end
  local p = ctx.player
  local mx, my = love.mouse.getPosition()

  if self.patch and #self.patch.slots ~= self.geometry.slots then self.geometry.slots = nil end

  if not self:playerNearby() then
    self.active = false
  elseif self.patch and not self.patch.growing and not self.patch.slot then
    self.active = true
  end

  self.active = true

  if self.active then
    local slots = self.geometry.slots
    for i = 1, #slots do
      local shruju = data.shruju[self.patch.slots[i]]
      local x, y, w, h = unpack(slots[i])
      if math.inside(mx, my, x, y, w, h) then
        ctx.hud.tooltip:setShrujuTooltip(shruju)
      end
    end
  end

  if (self.patch.growing or self.patch.slot) then
    local x, y, w, h = unpack(self.geometry.slot)
    if math.inside(mx, my, x, y, w, h) then
      ctx.hud.tooltip:setShrujuTooltip(data.shruju[self.patch.growing] or self.patch.slot)
    end

    if self.patch.slot and self.patch.slot.effect and love.math.random() < 4 * tickRate then
      ctx.particles:emit('magicshruju', x + w / 2, y + h / 2, 1)
    end

    if self.patch.growing and self.patch.timer < 2 * tickRate then
      self.slotScale = 1.4
    end
  end

  self.prevTime = self.time
  if self.active then self.time = math.min(self.time + tickRate, self.maxTime)
  else self.time = math.max(self.time - tickRate, 0) end

  self.prevGrowingFactor = self.growingFactor
  self.growingFactor = math.lerp(self.growingFactor, (self.patch.growing or self.patch.slot) and 1 or 0, math.min(8 * tickRate, 1))

  self.prevSlotScale = self.slotScale
  self.slotScale = math.lerp(self.slotScale, 1, math.min(10 * tickRate, 1))
end

function HudShrujuPatch:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local mx, my = love.mouse.getPosition()

  if self.patch then
    g.setFont('pixel', 8)

    local factor, t = self:getFactor()
    local alphaFactor = ((t / self.maxTime) ^ 4) * .7
    local growingFactor = math.lerp(self.prevGrowingFactor, self.growingFactor, tickDelta / tickRate)

    if t < 1 or (self.growingFactor > .01 and self.growingFactor < .99) then table.clear(self.geometry)
    elseif t == 0 then return end

    local slots = self.geometry.slots

    for i = 1, #slots do
      local shruju = data.shruju[self.patch.slots[i]]
      local x, y, w, h = unpack(slots[i])

      g.setColor(255, 255, 255, alphaFactor * 200)
      local image = data.media.graphics.hud.frame
      local scale = w / 125
      g.draw(image, x, y, 0, scale, scale)

      local image = data.media.graphics.shruju[self.patch.slots[i]] or data.media.graphics.shruju.juju
      local scale = (h - .02 * v) / image:getHeight()
      g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      local image = data.media.graphics.hud.title
      local scale = (w + 5) / 125
      g.draw(image, x + (w / 2), y + (120 * scale), 0, scale, scale, image:getWidth() / 2)

      g.setFont('pixel', 8)
      g.setColor(0, 0, 0, alphaFactor * 200)
      g.print(i, x + 6 + 1, y + 2 + 1)
      g.setColor(255, 255, 255, alphaFactor * 200)
      g.print(i, x + 6, y + 2)

      g.setFont('mesmerize', image:getHeight() * scale - 7)
      g.printCenter(shruju.name, x + (image:getWidth() * (w / 125)) / 2, y + (120 * scale) + (image:getHeight() * scale) / 2)
    end

    if self.growingFactor > 0 then
      g.setColor(255, 255, 255, (self.patch.slot and 200 or 120) * growingFactor)

      local code = (self.patch.growing or self.patch.slot) and (self.patch.growing or self.patch.slot.code) or nil

      local x, y, w, h = unpack(self.geometry.slot)
      local image = data.media.graphics.hud.frame
      local frameWidth = image:getWidth()
      local slotScale = math.lerp(self.prevSlotScale, self.slotScale, tickDelta / tickRate)
      local scale = (w / frameWidth) * slotScale
      g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      if code then
        local image = data.media.graphics.shruju[code] or data.media.graphics.shruju.juju
        local scale = (h - .02 * v) / image:getHeight() * slotScale
        g.draw(image, x + w / 2, y + h / 2, math.sin(tick / 10) / 10, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

        local image = data.media.graphics.hud.title
        local scale = (w + 5) / data.media.graphics.hud.frame:getWidth()
        g.setColor(255, 255, 255, (self.patch.growing and 80 or 255) * growingFactor)
        g.draw(image, x - (scale - (w / frameWidth)) * image:getWidth() / 2, y + (120 * scale), 0, scale, scale)

        if self.patch.growing then
          g.setColor(255, 255, 255 * growingFactor)
          g.draw(image, x - (scale - (w / frameWidth)) * image:getWidth() / 2, y + (120 * scale), 0, scale * (1 - (self.patch.timer / self.patch:getGrowTime(self.patch.growing))), scale)
        end

        g.setFont('mesmerize', image:getHeight() * scale - 7)
        local str = data.shruju[code].name
        if math.inside(mx, my, x - (scale - (w / frameWidth)) * image:getWidth() / 2, y + (120 * scale), image:getWidth() * scale, image:getHeight() * scale) then
          str = string.format('%.2f', self.patch.timer)
        end
        g.printCenter(str, x + (image:getWidth() * (w / frameWidth)) / 2, y + (120 * scale) + (image:getHeight() * scale) / 2)
      end
    end
  end
end

function HudShrujuPatch:keypressed(key)
  if self.patch and (key == 'tab' or key == 'e') then
    if self:playerNearby() and (self.patch.growing or self.patch.slot) then
      if self.patch.slot then
        local shruju = self.patch:take()
        shruju:eat()
        ctx.sound:play('nomnom')
        self.active = true
      else
        self.lastPress = tick
        self.active = not self.active
      end
    else
      self.lastPress = tick
      self.active = not self.active
    end
    if not self:playerNearby() then self.active = false end
  elseif self.patch and self.active and key:match('%d') then
    local i = tonumber(key)
    if i and i >= 1 and i <= #self.geometry.slots then
      local p = ctx.player
      self.patch:grow(i)
      self.active = false
    end
  end
end

function HudShrujuPatch:keyreleased(key)
  if self.patch and key == 'tab' or key == 'e' or key == 'escape' then
    if (tick - self.lastPress) * tickRate > self.maxTime then
      self.active = false
    end
  end
end

function HudShrujuPatch:mousepressed(x, y, b)
  if not self.patch or self.patch.timer > 0 then return end

  local p = ctx.player

  if self.active and b == 'l' then
    local slots = self.geometry.slots
    for i = 1, #slots do
      if math.inside(x, y, unpack(slots[i])) then
        self.patch:grow(i)
        self.active = false
      end
    end
  end

  if self:playerNearby() and self.patch.slot and math.inside(x, y, unpack(self.geometry.slot)) then
    if b == 'l' then
      local shruju = self.patch:take()
      shruju:eat()
      ctx.sound:play('nomnom')
      self.active = true
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
