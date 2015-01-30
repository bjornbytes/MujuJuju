local g = love.graphics
require 'lib/component'
Dropdown = extend(Component)

function Dropdown:activate()
  self.value = nil
  self.choices = self.choices or {}
end

function Dropdown:render()
  local u, v = ctx.u, ctx.v
  local x, y, w, h = unpack(self.geometry())
  local totalHeight = self:getHeight()

  g.setFont('mesmerize', h - .02 * v)

  g.setColor(0, 0, 0)
  g.rectangle('fill', x, y, w, totalHeight)

  g.setColor(200, 200, 200)
  g.rectangle('line', x, y, w, h)

  if self:focused() then
    for i = 1, #self.choices do
      if self.choices[i] == self.value then g.setColor(200, 255, 200)
      else g.setColor(220, 220, 220) end
      g.print(self.choices[i], x + .01 * v, y + h * i + .01 * v)
    end
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
  if b == 'l' and self.gooey.hot == self then
    if not self:focused() then
      if self:contains(mx, my) then
        self.gooey:focus(self)
      end
    else
      local hit = self:contains(mx, my)

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
  local i = 0
  local lim = self:focused() and #self.choices or 0

  for i = i, lim do
    if math.inside(mx, my, x, y + h * i, w, h) then
      return i
    end
  end

  return false
end

function Dropdown:getHeight()
  local h = self.geometry()[4]
  if not self:focused() then return h end
  return h * (#self.choices + 1)
end
