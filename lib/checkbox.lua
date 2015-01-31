local g = love.graphics
require 'lib/component'
Checkbox = extend(Component)

function Checkbox:activate()
  self.value = false
  self.scale = 1
  self.prevScale = self.scale
  self.tween = nil
end

function Checkbox:update()
  self.prevScale = self.scale
  local hover = self:contains(love.mouse.getPosition())
  self.scale = math.lerp(self.scale, hover and 1.15 or 1, math.min(16 * tickRate, 1))
end

function Checkbox:render()
  local x, y, r = unpack(self.geometry())

  local scale = math.lerp(self.prevScale, self.scale, tickDelta / tickRate)
  local radius = scale * r

  if self.value then g.setColor(0, 0, 0, 200)
  else g.setColor(0, 0, 0, 100) end
  g.circle('fill', x, y, radius, 20)

  g.setColor(255, 255, 255, 80 + (self.value and 170 or 0))
  if self.value then g.setColor(100, 200, 50) end
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
  self.scale = self.value and 1.4 or .9
  self:emit('change')
end

function Checkbox:contains(x, y)
  return math.insideCircle(x, y, unpack(self.geometry()))
end
