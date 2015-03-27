local g = love.graphics
require 'lib/component'
Button = extend(Component)

function Button:activate()
  self.hoverActive = false
  self.hoverFactor = 0
  self.prevHoverFactor = 0
  self.prevHoverFade = 0
  self.hoverX = nil
  self.hoverY = nil
  self.hoverDistance = 0
  self.hoverFade = 0
  self.disabled = false
end

function Button:update()
  self.prevHoverFactor = self.hoverFactor
  self.prevHoverFade = self.hoverFade
  if self.hoverActive then
    self.hoverFactor = math.lerp(self.hoverFactor, 1, math.min(8 * ls.tickrate, 1))
    if self.hoverFactor > .999 then
      self.hoverFade = math.min(self.hoverFade + ls.tickrate, 1)
    end
  else
    self.hoverFactor = 0
    self.hoverFade = 0
  end
end

function Button:mousepressed(mx, my, b)
  if b == 'l' and self:contains(mx, my) and not self.disabled then
    self.gooey.hot = self
  end
end

function Button:mousereleased(mx, my, b)
  if b == 'l' and self.gooey.hot == self and self:contains(mx, my) and not self.disabled then
    self:emit('click')
    ctx.sound:play('juju1', function(sound) sound:setPitch(1) end)
  end
end

function Button:render()
  local x, y, w, h = unpack(self.geometry())
  local text = self.text
  local mx, my = self:getMousePosition()
  local hover = self:contains(mx, my)
  local active = hover and love.mouse.isDown('l') and self.gooey.hot == self

  -- Button
  g.setColor(0, 0, 0, 85)
  g.rectangle('fill', x, y, w, h)

  local fade = math.lerp(self.prevHoverFade, self.hoverFade, ls.accum / ls.tickrate)
  g.setColor(0, 0, 0, 200)
  g.setLineWidth(2)
  local xx, yy = math.round(x) + .5, math.round(y) + .5
  w, h = math.floor(w), math.floor(h)
  g.line(xx, yy + h, xx + w, yy + h)
  g.line(xx + w, yy, xx + w, yy + h)
  g.setLineWidth(1)

  if hover then
    if not self.hoverActive then
      self.hoverX = mx
      self.hoverY = my
      local d = math.distance
      self.hoverDistance = math.max(d(mx, my, x, y), d(mx, my, x + w, y), d(mx, my, x, y + h), d(mx, my, x + w, y + h))
      ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
    end

    g.setColor(255, 255, 255)
    g.setStencil(function()
      g.rectangle('fill', x, y, w, h)
    end)

    local factor = math.lerp(self.prevHoverFactor, self.hoverFactor, ls.accum / ls.tickrate)
    g.setColor(255, 255, 255, 40 * (1 - fade))
    g.setBlendMode('alpha')
    g.circle('fill', self.hoverX, self.hoverY, factor * self.hoverDistance)
    g.setBlendMode('alpha')

    g.setStencil()

    self.hoverActive = true
  else
    self.hoverActive = false
  end

  -- Text
  if active then y = y + 2 end
  g.setFont('mesmerize', h * .55)
  g.setColor(0, 0, 0, 100)
  g.printCenter(text, x + w / 2 + 1, y + h / 2 + 1)
  g.setColor(255, 255, 255)
  g.printCenter(text, x + w / 2, y + h / 2)
end

function Button:contains(x, y)
  return math.inside(x, y, unpack(self.geometry())) and not self.disabled
end
