local g = love.graphics
local tween = require 'lib/deps/tween/tween'

MenuStart = class()

function MenuStart:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    start = function()
      local u, v = ctx.u, ctx.v
      local w = u * .25
      local h = w * .28
      return {u * .5 - w / 2, v * .7 - h / 2, w, h}
    end,

    options = function()
      local u, v = ctx.u, ctx.v
      local sx, sy, sw, sh = unpack(self.geometry.start)
      local w = u * .12
      local h = w * .28
      return {u * .5 - sw / 2, sy + sh + v * .01, w, h}
    end,

    quit = function()
      local u, v = ctx.u, ctx.v
      local sx, sy, sw, sh = unpack(self.geometry.start)
      local w = u * .12
      local h = w * .28
      return {u * .5 + v * .01, sy + sh + v * .01, w, h}
    end
  }

  self.scale = 0
  self.tween = tween.new(.5, self, {scale = 1}, 'outBack')

  self.start = ctx.gooey:add(Button, 'menu.start.start')
  self.start.geometry = function() return self.geometry.start end
  self.start.text = 'Start'
  self.start:on('click', function() self:continue() end)

  self.options = ctx.gooey:add(Button, 'menu.start.options')
  self.options.geometry = function() return self.geometry.options end
  self.options:on('click', function() ctx.optionsPane:toggle() end)
  self.options.text = 'Options'

  self.quit = ctx.gooey:add(Button, 'menu.start.quit')
  self.quit.geometry = function() return self.geometry.quit end
  self.quit:on('click', function() love.event.quit() end)
  self.quit.text = 'Quit'

  self.offsetX = 0
  self.offsetY = 0
  self.prevOffsetX = self.offsetX
  self.prevOffsetY = self.offsetY
end

function MenuStart:update()
  if not self.active then return end

  self.prevOffsetX = self.offsetX
  self.prevOffsetY = self.offsetY
  local u, v = ctx.u, ctx.v
  local image = data.media.graphics.menu.titlescreen
  local scale = math.max(u / image:getWidth(), v / image:getHeight()) * 1.05
  self.offsetX = math.lerp(self.offsetX, (.5 - (love.mouse.getX() / u)) * (u * .02), 2 * ls.tickrate)
  self.offsetY = math.lerp(self.offsetY, (.5 - (love.mouse.getY() / v)) * (v * .02), 2 * ls.tickrate)
end

function MenuStart:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v

  self.tween:update(ls.dt)
  local factor = self.scale

  g.setColor(255, 255, 255)
  data.media.shaders.vignette:send('frame', {0, 0, u, v})
  data.media.shaders.vignette:send('blur', .45)
  data.media.shaders.vignette:send('radius', .85)
  g.setShader(data.media.shaders.vignette)
  local image = data.media.graphics.menu.titlescreen
  local scale = math.max(u / image:getWidth(), v / image:getHeight()) * 1.05
  local offsetX = math.lerp(self.prevOffsetX, self.offsetX, ls.accum / ls.tickrate)
  local offsetY = math.lerp(self.prevOffsetY, self.offsetY, ls.accum / ls.tickrate)
  g.draw(image, u / 2 + offsetX, v / 2 + offsetY, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  g.setShader()

  local image = data.media.graphics.menu.title
  local scale = v * .45 / image:getHeight()
  g.draw(image, u * .5 + offsetX / 2, v * .3 + offsetY / 2, 0, scale * factor, scale * factor, image:getWidth() / 2, image:getHeight() / 2)

  self.start:draw()
  self.options:draw()
  self.quit:draw()
end

function MenuStart:keypressed(key)
  if not self.active then return end
end

function MenuStart:mousepressed(mx, my, b)
  --
end

function MenuStart:mousereleased(mx, my, b)
  if not self.active then return end
end

function MenuStart:gamepadpressed(gamepad, button)
  if not self.active then return end

  if button == 'b' and not ctx.optionsPane.active then
    love.event.quit()
  end
end

function MenuStart:resize()
  table.clear(self.geometry)
end

function MenuStart:continue()
  ctx:refreshBackground()
  ctx:goto('select')
end
