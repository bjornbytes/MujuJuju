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

  if not Menu.started then
    self.active = true
    Menu.started = true
    self.alpha = 1
    self.scale = 0
    self.tween = tween.new(.5, self, {scale = 1}, 'outBack')
  else
    self.active = false
    self.alpha = 0
    self.scale = 1
  end

  self.start = ctx.gooey:add(Button, 'menu.start.start')
  self.start.geometry = function() return self.geometry.start end
  self.start.text = 'Start'
  self.start:on('click', function() self:continue() end)

  self.options = ctx.gooey:add(Button, 'menu.start.options')
  self.options.geometry = function() return self.geometry.options end
  self.options:on('click', function() ctx.options:toggle() end)
  self.options.text = 'Options'

  self.quit = ctx.gooey:add(Button, 'menu.start.quit')
  self.quit.geometry = function() return self.geometry.quit end
  self.quit:on('click', function() love.event.quit() end)
  self.quit.text = 'Quit'
end

function MenuStart:update()
  self.active = (ctx.page == 'start')
  if not self.active then
    self.alpha = math.max(self.alpha - tickRate, 0)
  end
end

function MenuStart:draw()
  if self.alpha > 0 then
    local u, v = ctx.u, ctx.v

    self.tween:update(delta)
    local factor = self.scale

    g.setColor(255, 255, 255)
    local image = data.media.graphics.menu.titlescreen
    local scale = math.max(u / image:getWidth(), v / image:getHeight())
    g.draw(image, u / 2, v / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    local image = data.media.graphics.menu.title
    local scale = v * .45 / image:getHeight()
    g.draw(image, u * .5, v * .3, 0, scale * factor, scale * factor, image:getWidth() / 2, image:getHeight() / 2)

    self.start:draw()
    self.options:draw()
    self.quit:draw()
  end
end

function MenuStart:keypressed(key)
  if not self.active then return end
  if key == 'return' then
    self:continue()
  end
end

function MenuStart:mousepressed(mx, my, b)
  --
end

function MenuStart:mousereleased(mx, my, b)
  if not self.active then return end
end

function MenuStart:continue()
  ctx:refreshBackground()
  self.active = false

  if not ctx.user.deck or (#ctx.user.deck.minions == 0 and #ctx.user.minions == 0) then
    ctx.page = 'choose'
  else
    ctx.page = 'main'
  end
end
