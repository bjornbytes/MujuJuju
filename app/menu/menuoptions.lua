local tween = require('lib/deps/tween/tween')
local g = love.graphics

MenuOptions = class()

function MenuOptions:init()
  self.active = false
  self.offset = 0
  self.tweenDuration = .25
  self.width = .35
  self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'outBack')
  self.canvas = g.newCanvas((self.width + .05) * ctx.u, ctx.v)
end

function MenuOptions:update()
  --
end

function MenuOptions:draw()
  self.offsetTween:update(delta)
  
  local u, v = ctx.u, ctx.v

  if self.offset > -1 then return end
  
  local x1 = u + self.offset
  local width = self.width * u

  self.canvas:clear(0, 0, 0, 0)
  ctx.workingCanvas:clear(0, 0, 0, 0)
  g.setColor(255, 255, 255)
  g.setCanvas(self.canvas)
  g.draw(ctx.screenCanvas, -u - self.offset, 0)
  g.setCanvas()

  if self.offset / -width > .1 then
    for i = 1, 4 do
      local shader = data.media.shaders.horizontalBlur
      shader:send('amount', .002 * (self.offset / -width))
      g.setShader(shader)
      ctx.workingCanvas:renderTo(function()
        g.draw(self.canvas)
      end)
      
      shader = data.media.shaders.verticalBlur
      shader:send('amount', .002 * (self.offset / -width))
      g.setShader(shader)
      self.canvas:renderTo(function()
        g.draw(ctx.workingCanvas)
      end)
    end
    g.setShader()
  end

  g.draw(self.canvas, x1, 0)

  g.setColor(0, 0, 0, 150)
  g.rectangle('fill', x1, 0, width + .05 * u, v)

  g.setColor(200, 200, 200)
  g.setFont('mesmerize', .05 * v)
  g.printCenter('Options', x1 + width / 2, .05 * v)

  g.setFont('mesmerize', .03 * v)
  g.setColor(255, 255, 255)
  g.print('Graphics', x1 + .03 * v, .15 * v)
  g.print('Sound', x1 + .03 * v, .5 * v)
  g.print('Input', x1 + .03 * v, .7 * v)
end

function MenuOptions:keypressed(key)
  if key == ' ' then
    self:toggle()
  end
end

function MenuOptions:toggle()
  if self.active then
    self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'inBack')
  else
    self.offsetTween = tween.new(self.tweenDuration, self, {offset = -self.width * ctx.u}, 'outBack')
  end
  self.active = not self.active
end
