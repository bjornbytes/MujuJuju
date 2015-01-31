local g = love.graphics
require 'lib/component'
Dropdown = extend(Component)

function Dropdown:activate()
  self.value = nil
  self.choices = self.choices or {}
  self.factor = 0
  self.prevFactor = 0
  self.hoverFactors = {}
  self.prevHoverFactors = {}
end

function Dropdown:update()
  self.prevFactor = self.factor
  self.factor = math.lerp(self.factor, self:focused() and 1 or 0, math.min(16 * tickRate, 1))
  if self:focused() then
    local hoverIndex = self:contains(love.mouse.getPosition())
    local hoverAmount = 1 + (love.mouse.isDown('l') and .5 or 0)
    for i = 1, #self.choices do
      self.prevHoverFactors[i] = self.hoverFactors[i] or 0
      self.hoverFactors[i] = math.lerp(self.prevHoverFactors[i], i == hoverIndex and hoverAmount or 0, math.min(16 * tickRate, 1))
    end
  end
end

function Dropdown:render()
  local u, v = ctx.u, ctx.v
  local x, y, w, h = unpack(self.geometry())
  local hoverIndex = self:contains(love.mouse.getPosition())
  local hoverFactors = table.interpolate(self.prevHoverFactors, self.hoverFactors, tickDelta / tickRate)
  local factor = math.lerp(self.prevFactor, self.factor, tickDelta / tickRate)
  local dropdownHeight = self:getDropdownHeight() * factor

  g.setFont('mesmerize', h - .02 * v)

  g.setColor(255, 255, 255, 40)
  g.rectangle('fill', x, y, w, h)

  g.setColor(0, 0, 0, 255 * factor)
  g.rectangle('fill', x, y + h, w, dropdownHeight)

  if hoverIndex and hoverIndex > 0 then
    g.setColor(255, 255, 255, 30 * hoverFactors[hoverIndex])
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
      hoverFactor = hoverFactors[i]
    end
    local alpha = math.min(180 * factor + (75 * hoverFactor), 255)
    if self.choices[i] == self.value then g.setColor(100, 200, 50, 255 * factor)
    else g.setColor(220, 220, 220, alpha) end
    g.print(self.choices[i], x + .01 * v, y + h * i + .01 * v)
  end

  g.setColor(255, 255, 255)
  g.print(self.value, x + .01 * v, y + .01 * v)
end

function Dropdown:mousepressed(mx, my, b)
  if b == 'l' and self:contains(mx, my) then
    self.gooey.hot = self
    if self:focused() then return true end
  end
end

function Dropdown:mousereleased(mx, my, b)
  if b == 'l' then
    if not self:focused() then
      if self.gooey.hot == self and self:contains(mx, my) then
        self.gooey:focus(self)
      end
    else
      local hit = self.gooey.hot == self and self:contains(mx, my)

      self.gooey:unfocus()
      if hit then
        self.value = self.choices[hit] or self.value
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
