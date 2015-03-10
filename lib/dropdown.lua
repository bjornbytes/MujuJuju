local g = love.graphics
require 'lib/component'
Dropdown = extend(Component)

function Dropdown:activate()
  self.value = nil
  self.choices = self.choices or {}
  self.factor = 0
  self.prevFactor = self.factor
  self.hoverFactor = 0
  self.prevHoverFactor = self.hoverFactor
  self.choiceHoverFactors = {}
  self.prevChoiceHoverFactors = {}
  self.hoverDirty = false
end

function Dropdown:update()
  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  local hover = self:contains(mx, my)
  self.prevFactor = self.factor
  self.prevHoverFactor = self.hoverFactor
  self.factor = math.lerp(self.factor, self:focused() and 1 or 0, math.min(16 * ls.tickrate, 1))
  self.hoverFactor = math.lerp(self.hoverFactor, (self:focused() or hover) and 1 or 0, math.min(16 * ls.tickrate, 1))
  if self:focused() then
    local hoverIndex = self:contains(mx, my)
    local hoverAmount = 1 + (love.mouse.isDown('l') and .5 or 0)
    for i = 1, #self.choices do
      self.prevChoiceHoverFactors[i] = self.choiceHoverFactors[i] or 0
      self.choiceHoverFactors[i] = math.lerp(self.prevChoiceHoverFactors[i], i == hoverIndex and hoverAmount or 0, math.min(16 * ls.tickrate, 1))
    end

    if hover then
      if self.hoverDirty ~= hoverIndex and hoverIndex ~= 0 and (not self.gooey.focused or self.gooey.focused == self) then
        ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
        self.hoverDirty = hoverIndex
      end
    else
      self.hoverDirty = false
    end
  end

  if hover then
    if not self.hoverDirty and (not self.gooey.focused or self.gooey.focused == self) then
      ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
      self.hoverDirty = true
    end
  else
    self.hoverDirty = false
  end
end

function Dropdown:render()
  local u, v = ctx.u, ctx.v
  local x, y, w, h = unpack(self.geometry())
  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  local hoverIndex = self:contains(mx, my)
  local choiceHoverFactors = table.interpolate(self.prevChoiceHoverFactors, self.choiceHoverFactors, ls.accum / ls.tickrate)
  local hoverFactor = math.lerp(self.prevHoverFactor, self.hoverFactor, ls.accum / ls.tickrate)
  local factor = math.lerp(self.prevFactor, self.factor, ls.accum / ls.tickrate)
  local dropdownHeight = self:getDropdownHeight() * factor
  local font = g.setFont('mesmerize', h - .02 * v)

  g.setColor(255, 255, 255, 40 + (20 * hoverFactor))
  g.rectangle('fill', x, y, w, h)

  g.setColor(0, 0, 0, 255 * factor)
  g.rectangle('fill', x, y + h, w, dropdownHeight)

  if hoverIndex and hoverIndex > 0 then
    g.setColor(255, 255, 255, 30 * choiceHoverFactors[hoverIndex])
    g.rectangle('fill', x, y + h * hoverIndex, w, h)
  end

  --[[g.setColor(255, 255, 255, 255)
  g.rectangle('line', math.round(x) + .5, math.round(y) + .5, w, h)]]

  for i = 1, #self.choices do
    local factor = factor
    local hoverFactor = 0
    if self:focused() then
      local prev = self:getDropdownHeight() * (i - 1) / #self.choices
      factor = math.clamp((dropdownHeight - prev) / h, 0, 1) ^ 4
      hoverFactor = choiceHoverFactors[i]
    end
    local alpha = math.min(180 * factor + (75 * hoverFactor), 255)
    if self.choices[i] == self.value then g.setColor(100, 200, 50, 255 * factor)
    else g.setColor(220, 220, 220, alpha) end
    g.print(self.choices[i], x + .01 * v, y + h * i + .01 * v)
  end

  g.setColor(255, 255, 255)
  g.print(self.label, x + .01 * v, y + .01 * v)

  g.setColor(100, 200, 50, 255)
  g.print(self.value, x + w - .01 * v - font:getWidth(self.value), y + .01 * v)
end

function Dropdown:mousepressed(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  if b == 'l' and self:contains(mx, my) then
    self.gooey.hot = self
    if self:focused() then return true end
  end
end

function Dropdown:mousereleased(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy

  if b == 'l' then
    if not self:focused() then
      if self.gooey.hot == self and self:contains(mx, my) then
        self.gooey:focus(self)
        ctx.sound:play('juju1', function(sound) sound:setPitch(1) end)
      end
    else
      local hit = self.gooey.hot == self and self:contains(mx, my)

      self.gooey:unfocus()
      if hit then
        self.value = self.choices[hit] or self.value
        self:emit('change', {component = self})
        ctx.sound:play('juju1', function(sound) sound:setPitch(1) end)
        return true
      end
    end
  end
end

function Dropdown:contains(mx, my)
  local x, y, w, h = unpack(self.geometry())
  if math.inside(mx, my, x, y, w, h) then return 0 end

  if self:focused() then
    for i = 1, #self.choices do
      if math.inside(mx, my, x, y + h * i, w, h) then
        return i
      end
    end
  end

  return false
end

function Dropdown:getDropdownHeight()
  local h = self.geometry()[4]
  return h * (#self.choices)
end
