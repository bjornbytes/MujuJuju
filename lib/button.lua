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
  end
end

function Button:render()
  local x, y, w, h = unpack(self.geometry())
  local text = self.text
  local mx, my = self:getMousePosition()
  local hover = self:contains(mx, my)
  local active = hover and love.mouse.isDown('l') and self.gooey.hot == self

  -- Button
  local button = data.media.graphics.menu.button
  local buttonActive = data.media.graphics.menu.buttonActive
  local diff = (button:getHeight() - buttonActive:getHeight())
  local image = active and buttonActive or button
  local bgy = y + h
  local yscale = h / button:getHeight()
  g.setColor(255, 255, 255)
  --g.draw(image, x, bgy, 0, w, yscale, 0, image:getHeight())
  g.setColor(255, 255, 255, 60)
  g.rectangle('fill', x, y, w, h)

  local fade = math.lerp(self.prevHoverFade, self.hoverFade, ls.accum / ls.tickrate)
  g.setColor(0, 0, 0, 200)
  --g.rectangle('line', math.round(x) + .5, math.round(y) + .5, w, h)
  local xx, yy = math.round(x) + .5, math.round(y) + .5
  w, h = math.floor(w), math.floor(h)
  g.line(xx, yy + h, xx + w, yy + h)
  g.line(xx + w, yy, xx + w, yy + h)

  if hover then
    if not self.hoverActive then
      self.hoverX = mx
      self.hoverY = my
      local d = math.distance
      self.hoverDistance = math.max(d(mx, my, x, y), d(mx, my, x + w, y), d(mx, my, x, y + h), d(mx, my, x + w, y + h))
    end

    g.setColor(255, 255, 255)
    g.setStencil(function()
      --local y = active and y + diff * yscale or y
      --local h = active and h - diff * yscale or h - diff * yscale
      g.rectangle('fill', x, y, w, h)
    end)

    local factor = math.lerp(self.prevHoverFactor, self.hoverFactor, ls.accum / ls.tickrate)
    g.setColor(255, 255, 255, 20 * (1 - fade))
    g.setBlendMode('additive')
    g.circle('fill', self.hoverX, self.hoverY, factor * self.hoverDistance)
    g.setBlendMode('alpha')

    --[[g.setColor(255, 255, 255, 10)
    g.setBlendMode('subtractive')
    g.circle('fill', self.hoverX, self.hoverY, (factor ^ 2) * self.hoverDistance)
    g.setBlendMode('alpha')]]

    g.setStencil()

    self.hoverActive = true
  else
    self.hoverActive = false
  end

  -- Text
  --if active then y = y + diff * yscale end
  if active then y = y + 2 end
  g.setFont('mesmerize', h * .55)
  g.setColor(0, 0, 0, 100)
  --g.printCenter(text, x + w / 2 + 1, y + (h - diff * yscale) / 2 + 1)
  g.printCenter(text, x + w / 2 + 1, y + h / 2 + 1)
  g.setColor(255, 255, 255)
  --g.printCenter(text, x + w / 2, y + (h - diff * yscale) / 2)
  g.printCenter(text, x + w / 2, y + h / 2)
end

function Button:contains(x, y)
  return math.inside(x, y, unpack(self.geometry())) and not self.disabled
end
