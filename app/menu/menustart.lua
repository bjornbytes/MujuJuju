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
      local image = data.media.graphics.menu.start
      local w = u * .25
      local h = w * (image:getHeight() / image:getWidth())
      return {u * .5 - w / 2, v * .7 - h / 2, w, h}
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
    local scale = math.min(u / image:getWidth(), v / image:getHeight())
    g.draw(image, 0, 0, 0, scale, scale)

    local image = data.media.graphics.menu.title
    local scale = v * .45 / image:getHeight()
    g.draw(image, u * .5, v * .3, 0, scale * factor, scale * factor, image:getWidth() / 2, image:getHeight() / 2)

    local x, y, w, h = unpack(self.geometry.start)
    ctx:drawButton('Start', x, y, w, h)
  end
end

function MenuStart:keypressed(key)
  if not self.active then return end
  if key == 'return' then
    self:start()
  end
end

function MenuStart:mousepressed(mx, my, b)
  --
end

function MenuStart:mousereleased(mx, my, b)
  if not self.active then return end
  if math.inside(mx, my, unpack(self.geometry.start)) then
    ctx.sound:play('menuClick')
    self:start()
  end
end

function MenuStart:start()
  ctx:refreshBackground()
  self.active = false

  if not ctx.user.deck or (#ctx.user.deck.minions == 0 and #ctx.user.minions == 0) then
    ctx.page = 'choose'
  else
    ctx.page = 'main'
  end
end
