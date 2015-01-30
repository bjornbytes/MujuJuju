local g = love.graphics
require 'lib/component'
Checkbox = extend(Component)

function Checkbox:activate()
  self.value = false
  self.scale = 1
  self.tween = nil
end

function Checkbox:render()
  local x, y, r = unpack(self.geometry())

  self.scale = math.lerp(self.scale, 1, math.min(6 * delta, 1))
  local radius = self.scale * r

  if self.value then
    g.setColor(100, 200, 50)
    g.circle('fill', x, y, radius, 20)
  end

  g.setColor(255, 255, 255)
  g.setLineWidth(2)
  g.circle('line', x, y, radius, 20)
  g.setLineWidth(1)
end

function Checkbox:mousepressed(mx, my, b)
  
end

function Checkbox:mousereleased(mx, my, b)
  if b == 'l' and self:contains(mx, my) then
    self:toggle()
  end
end

function Checkbox:toggle()
  self.value = not self.value
  self.scale = self.value and 1.5 or .67
end

function Checkbox:contains(x, y)
  return math.insideCircle(x, y, unpack(self.geometry()))
end
