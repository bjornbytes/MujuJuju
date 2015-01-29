local g = love.graphics
Button = class()

function Button:init()
  self.states = {}
end

function Button:update()
  table.each(self.states, function(state)
    state.prevHoverFactor = state.hoverFactor
    if state.hoverActive then
      state.hoverFactor = math.lerp(state.hoverFactor, 1, math.min(8 * tickRate, 1))
      ctx.cursor:hover()
    else
      state.hoverFactor = 0
    end
  end)
end

function Button:draw(text, x, y, w, h)

  -- Button
  local mx, my = love.mouse.getPosition()
  local hover = math.inside(mx, my, x, y, w, h)
  local active = hover and love.mouse.isDown('l')
  local button = data.media.graphics.menu.button
  local buttonActive = data.media.graphics.menu.buttonActive
  local diff = (button:getHeight() - buttonActive:getHeight())
  local image = active and buttonActive or button
  local bgy = y + h
  local yscale = h / button:getHeight()
  g.draw(image, x, bgy, 0, w, yscale, 0, image:getHeight())

  local state = self.states[text] or self:makeState(text)

  if hover then
    if not state.hoverActive then
      state.hoverX = mx
      state.hoverY = my
      local d = math.distance
      state.hoverDistance = math.max(d(mx, my, x, y), d(mx, my, x + w, y), d(mx, my, x, y + h), d(mx, my, x + w, y + h))
    end

    g.setColor(255, 255, 255)
    g.setStencil(function()
      local y = active and y + diff * yscale or y
      local h = active and h - diff * yscale or h - diff * yscale
      g.rectangle('fill', x, y, w, h)
    end)

    local factor = math.lerp(state.prevHoverFactor, state.hoverFactor, tickDelta / tickRate)
    g.setColor(255, 255, 255, 20)
    g.setBlendMode('additive')
    g.circle('fill', state.hoverX, state.hoverY, factor * state.hoverDistance)
    g.setBlendMode('alpha')

    g.setColor(255, 255, 255, 10)
    g.setBlendMode('subtractive')
    g.circle('fill', state.hoverX, state.hoverY, (factor ^ 2) * state.hoverDistance)
    g.setBlendMode('alpha')

    g.setStencil()

    state.hoverActive = true
  else
    state.hoverActive = false
  end

  -- Text
  if active then y = y + diff * yscale end
  g.setFont('mesmerize', h * .55)
  g.setColor(0, 0, 0, 100)
  g.printCenter(text, x + w / 2 + 1, y + (h - diff * yscale) / 2 + 1)
  g.setColor(255, 255, 255)
  g.printCenter(text, x + w / 2, y + (h - diff * yscale) / 2)
end

function Button:makeState(key)
  self.states[key] = {
    hoverActive = false,
    hoverFactor = 0,
    prevHoverFactor = 0,
    hoverX = nil,
    hoverY = nil,
    hoverDistance = 0
  }
  return self.states[key]
end
