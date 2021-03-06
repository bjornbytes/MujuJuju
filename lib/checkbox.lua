local g = love.graphics
require 'lib/component'
Checkbox = extend(Component)

function Checkbox:activate()
  self.value = self.value == nil and false or self.value
  self.scale = 1
  self.prevScale = self.scale
  self.factor = 0
  self.prevFactor = self.factor
  self.hoverDirty = false
end

function Checkbox:update()
  self.prevScale = self.scale
  self.prevFactor = self.factor

  local mx, my = love.mouse.getPosition()
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy

  local hover = self:contains(mx, my)
  self.scale = math.lerp(self.scale, hover and 1.15 or 1, math.min(16 * ls.tickrate, 1))

  self.factor = math.lerp(self.factor, self.value and 1 or 0, math.min(16 * ls.tickrate, 1))

  if self:contains(mx, my) then
    if not self.hoverDirty and not self.gooey.focused then
      ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
      self.hoverDirty = true
    end
  else
    self.hoverDirty = false
  end
end

function Checkbox:render()
  local u, v = ctx.u, ctx.v
  local x, y, r = unpack(self.geometry())

  local factor = math.lerp(self.prevFactor, self.factor, ls.accum / ls.tickrate)
  local scale = math.lerp(self.prevScale, self.scale, ls.accum / ls.tickrate)
  local radius = scale * r

  if self.value then g.setColor(0, 0, 0, 200)
  else g.setColor(0, 0, 0, 100) end
  g.circle('fill', x, y, radius, 20)

  g.setColor(255, 255, 255, 80 + (self.value and 170 or 0))
  if self.value then g.setColor(100, 200, 50) end
  g.setLineWidth(2)
  g.circle('line', x, y, radius, 20)
  g.setLineWidth(1)

  g.setFont('mesmerize', r * 1.4)
  g.setColor(255, 255, 255, 180 + (75 * factor))
  g.print(self.label, x + r + 1.4 * r, y - g.getFont():getHeight() / 2)
end

function Checkbox:mousepressed(mx, my, b)
  
end

function Checkbox:mousereleased(mx, my, b)
  local ox, oy = self:getOffset()
  mx, my = mx + ox, my + oy
  if b == 'l' and self:contains(mx, my) and not self.gooey.focused then
    ctx.sound:play('juju1', function(sound) sound:setPitch(1) end)
    self:toggle()
  end
end

function Checkbox:toggle()
  self.value = not self.value
  self.scale = self.value and 1.4 or .9
  self:emit('change', {component = self})
end

function Checkbox:contains(mx, my)
  local x, y, r = unpack(self.geometry())
  local font = g.setFont('mesmerize', r * 1.4)
  local x1 = x - r
  local y1 = y - r
  local str = self.label
  return math.inside(mx, my, x1, y1, r + r + 1.4 * r + font:getWidth(str), font:getHeight())
end
