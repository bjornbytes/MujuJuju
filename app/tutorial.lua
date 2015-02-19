local g = love.graphics
local tween = require 'lib/deps/tween/tween'
Tutorial = class()

function Tutorial:init()
  self.messages = {
    'This is Muju',
    'You can move Muju with A and D',
  }

  self.messageIndex = 1

  self.active = true
  self.time = 0
  self.prevTime = self.time
  self.maxTime = .45
  self.factor = {value = 0}
  self.tween = tween.new(self.maxTime, self.factor, {value = 1}, 'inOutBack')
  self.delay = self.maxTime

  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Tutorial:update()
  self.prevTime = self.time
  if self.active then
    self.delay = timer.rot(self.delay)
    if self.delay == 0 then
      self.time = math.min(self.time + ls.tickrate, self.maxTime)
    end
  else
    self.delay = timer.rot(self.delay)
    if self.delay == 0 then
      self.time = math.max(self.time - ls.tickrate, 0)
      if self.time == 0 then
        self.messageIndex = self.messageIndex + 1
        self.active = true
      end
    end
  end

  if self.active and self.delay == 0 then
    if self.messageIndex == 1 and love.keyboard.isDown(' ') then
      self.active = false
    elseif self.messageIndex == 2 and ctx.player.x ~= ctx.map.width / 2 then
      self.active = false
      self.delay = .5
    end
  end
end

function Tutorial:gui()
  local u, v = ctx.view.frame.width, ctx.view.frame.height
  local font = g.setFont('mesmerize', .06 * v)

  if self.messageIndex <= #self.messages then
    local str = self.messages[self.messageIndex]
    local factor, t = self:getFactor()
    local alpha = (t / self.maxTime) ^ 3
    local x, y = u * .5, .35 * v * factor
    local w, h = font:getWidth(str), font:getHeight(str)
    local padding = u * .01

    g.setColor(0, 0, 0, 200 * alpha)
    g.rectangle('fill', x - w / 2 - padding, y - h / 2 - padding, w + 2 * padding, h + 2 * padding)

    g.setColor(255, 255, 255, 255 * alpha)
    g.printShadow(str, x, y, true)

    if self.messageIndex == 1 then
      local image = data.media.graphics.tutorial.space
      local scale = u * .2 / image:getWidth()
      g.draw(image, x, y + h / 2 + padding * 2 + image:getHeight() / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  end
end

function Tutorial:keypressed(key)
  --
end

function Tutorial:getFactor()
  local t = math.lerp(self.prevTime, self.time, ls.accum / ls.tickrate)
  self.tween:set(t)
  return self.factor.value, t
end
