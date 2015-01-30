local g = love.graphics
require 'lib/component'
Button = extend(Component)

function Button:activate()
  self.hoverActive = false
  self.hoverFactor = 0
  self.prevHoverFactor = 0
  self.hoverX = nil
  self.hoverY = nil
  self.hoverDistance = 0
end

function Button:update()
  self.prevHoverFactor = self.hoverFactor
  if self.hoverActive then
    self.hoverFactor = math.lerp(self.hoverFactor, 1, math.min(8 * tickRate, 1))
    ctx.cursor:hover()
  else
    self.hoverFactor = 0
  end
end

function Button:draw()
  self.gooey:draw(self)
end

function Button:mousereleased(mx, my, b)
  if math.inside(mx, my, unpack(self.geometry())) then
    self:emit('click')
  end
end

function Button:render()
  local x, y, w, h = unpack(self.geometry())
  local text = self.text
  local mx, my = love.mouse.getPosition()
  local hover = math.inside(mx, my, x, y, w, h)
  local active = hover and love.mouse.isDown('l')

  -- Button
  local button = data.media.graphics.menu.button
  local buttonActive = data.media.graphics.menu.buttonActive
  local diff = (button:getHeight() - buttonActive:getHeight())
  local image = active and buttonActive or button
  local bgy = y + h
  local yscale = h / button:getHeight()
  g.draw(image, x, bgy, 0, w, yscale, 0, image:getHeight())

  if hover then
    if not self.hoverActive then
      self.hoverX = mx
      self.hoverY = my
      local d = math.distance
      self.hoverDistance = math.max(d(mx, my, x, y), d(mx, my, x + w, y), d(mx, my, x, y + h), d(mx, my, x + w, y + h))
    end

    g.setColor(255, 255, 255)
    g.setStencil(function()
      local y = active and y + diff * yscale or y
      local h = active and h - diff * yscale or h - diff * yscale
      g.rectangle('fill', x, y, w, h)
    end)

    local factor = math.lerp(self.prevHoverFactor, self.hoverFactor, tickDelta / tickRate)
    g.setColor(255, 255, 255, 20)
    g.setBlendMode('additive')
    g.circle('fill', self.hoverX, self.hoverY, factor * self.hoverDistance)
    g.setBlendMode('alpha')

    g.setColor(255, 255, 255, 10)
    g.setBlendMode('subtractive')
    g.circle('fill', self.hoverX, self.hoverY, (factor ^ 2) * self.hoverDistance)
    g.setBlendMode('alpha')

    g.setStencil()

    self.hoverActive = true
  else
    self.hoverActive = false
  end

  -- Text
  if active then y = y + diff * yscale end
  g.setFont('mesmerize', h * .55)
  g.setColor(0, 0, 0, 100)
  g.printCenter(text, x + w / 2 + 1, y + (h - diff * yscale) / 2 + 1)
  g.setColor(255, 255, 255)
  g.printCenter(text, x + w / 2, y + (h - diff * yscale) / 2)
end
