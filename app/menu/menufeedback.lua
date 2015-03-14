local g = love.graphics
local tween = require 'lib/deps/tween/tween'

MenuFeedback = class()

function MenuFeedback:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    button = function()
      local u, v = ctx.u, ctx.v
      local w, h = .1 * u, .05 * v
      return {.02 * v * self.factor, v - h - .02 * v * self.factor, w, h}
    end
  }

  self.button = ctx.gooey:add(Button, 'menu.feedback.button')
  self.button.geometry = function() return self.geometry.button end
  self.button.text = 'Feedback'
  self.button:on('click', function()
    self:toggle()
  end)

  self.focused = false
  self.factor = 0
  self.tweenDuration = .4
  self.tweenMethod = 'inOutQuint'
  self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)

  self.input = ''
end

function MenuFeedback:update()

end

function MenuFeedback:draw()

  local u, v = ctx.u, ctx.v

  self.tween:update(ls.dt)

  if self.tween.clock < self.tweenDuration then
    table.clear(self.geometry)
  end

  local w, h = u * .35, v * .35
  local x, y = 0, v - (h * self.factor)

  g.setColor(0, 0, 0, 80)
  g.rectangle('fill', x, y, w, h)

  g.setColor(255, 255, 255)
  g.setFont('mesmerize', .03 * v)
  g.print('Feedback', x + .02 * v, y + .01 * v)

  local tw, th = w - .04 * v, h - .15 * v
  local tx, ty = x + .02 * v, y + .06 * v
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', tx, ty, tw, th)

  g.setColor(255, 255, 255, 40)
  g.rectangle('line', tx, ty, tw, th)

  g.setColor(255, 255, 255)
  g.setScissor(tx + 1, ty + 1, tw - 2, th - 2)
  g.setFont('mesmerize', .02 * v)
  g.printf(self.input, tx + .01 * v, ty + .01 * v, tw - .02 * v)
  g.setScissor()

  self.button:draw()
end

function MenuFeedback:keypressed(key)
  if key == 'backspace' then
    self.input = self.input:sub(1, -2)
  end
end

function MenuFeedback:textinput(char)
  self.input = self.input .. char
end

function MenuFeedback:toggle()
  if self.tween.clock < self.tweenDuration then return end
  if self.focused then
    self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)
    self.button.text = 'Feedback'
  else
    self.tween = tween.new(self.tweenDuration, self, {factor = 1}, self.tweenMethod)
    self.button.text = 'Send'
  end
  self.focused = not self.focused
end
