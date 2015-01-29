local tween = require 'lib/deps/tween/tween'
local g = love.graphics
Checkbox = class()

function Checkbox:init()
  self.states = {}
end

function Checkbox:draw(x, y, checked, code)
  local state = self.states[code] or self:makeState(code)
  if checked and not state.active or not checked and state.active then
    self:toggle(code)
  end

  state.scale = math.lerp(state.scale, 1, math.min(6 * delta, 1))

  local radius = state.scale * 10
  if checked then
    g.setColor(100, 200, 50)
    g.circle('fill', x, y, radius, 20)
  end

  g.setColor(255, 255, 255)
  g.setLineWidth(2)
  g.circle('line', x, y, radius, 20)
  g.setLineWidth(1)
end

function Checkbox:makeState(code)
  self.states[code] = {
    active = false,
    scale = 1,
    tween = nil
  }

  return self.states[code]
end

function Checkbox:toggle(code)
  local state = self.states[code] or self:makeState(code)
  state.active = not state.active
  state.scale = state.active and 1.5 or .5
end
