local tween = require 'lib/deps/tween/tween'
local g = love.graphics

Menu = class()
Menu.started = false

function Menu:load(selectedBiome)
  data.load()
	self.sound = Sound()
	self.menuSounds = self.sound:loop('menu')
	love.mouse.setCursor(love.mouse.newCursor('media/graphics/cursor.png'))

  if not love.filesystem.exists('save/user.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(config.defaultUser))
  end

  local str = love.filesystem.read('save/user.json')
  self.user = json.decode(str)

  self.u, self.v = love.graphics.getDimensions()
  self.tooltip = Tooltip()

  self:initAnimations()

  self.backgroundAlpha = 0
  self.prevBackgroundAlpha = self.backgroundAlpha
  self.background1 = g.newCanvas(self.u, self.v)
  self.background2 = g.newCanvas(self.u, self.v)
  self.workingCanvas = g.newCanvas(self.u, self.v)
  self.unitCanvas = g.newCanvas(400, 400)

  self.buttonHoverActive = false
  self.buttonHoverFactor = 0
  self.prevButtonHoverFactor = 0
  self.buttonHoverX = nil
  self.buttonHoverY = nil
  self.buttonHoverDistance = 0

  self.start = MenuStart()
  self.choose = MenuChoose()
  self.main = MenuMain()

  self.main.selectedBiome = selectedBiome or self.main.selectedBiome

  self.page = 'start'

  love.keyboard.setKeyRepeat(true)
end

function Menu:update()
  self.tooltip:update()

  self.prevBackgroundAlpha = self.backgroundAlpha
  self.backgroundAlpha = math.lerp(self.backgroundAlpha, 1, math.min(8 * tickRate, 1))

  self.prevButtonHoverFactor = self.buttonHoverFactor
  if self.buttonHoverActive then
    self.buttonHoverFactor = math.lerp(self.buttonHoverFactor, 1, math.min(8 * tickRate, 1))
  else
    self.buttonHoverFactor = 0
  end

  self.start:update()
  self.choose:update()
  self.main:update()
end

function Menu:draw()
  self.frameIndex = self.frameIndex or 0
  self.frameIndex = self.frameIndex + 1
  if self.frameIndex < 3 then
    delta = 0
  end

  self.start:draw()
  self:drawBackground()
  self.choose:draw()
  self.main:draw()

  self.tooltip:draw()
end

function Menu:keypressed(key)
  self.start:keypressed(key)
  self.choose:keypressed(key)
  self.main:keypressed(key)
end

function Menu:mousepressed(mx, my, b)
  self.start:mousepressed(mx, my, b)
  self.choose:mousepressed(mx, my, b)
  self.main:mousepressed(mx, my, b)
end

function Menu:mousereleased(mx, my, b)
  self.start:mousereleased(mx, my, b)
  self.choose:mousereleased(mx, my, b)
  self.main:mousereleased(mx, my, b)
end

function Menu:textinput(char)
  self.choose:textinput(char)
end

function Menu:startGame()
  if self.menuSounds then self.menuSounds:stop() end
  Context:remove(ctx)
  Context:add(Game, self.user, config.biomeOrder[self.main.selectedBiome])
end

function Menu:refreshBackground()
  local u, v = self.u, self.v

  g.setColor(255, 255, 255)
  self.background2:renderTo(function()
    g.draw(self.background1)
  end)

  self.background1:clear(255, 255, 255, 0)
  self.workingCanvas:clear(255, 255, 255, 0)

  self.background1:renderTo(function()
    local image = data.media.graphics.map[config.biomeOrder[self.main.selectedBiome]]
    g.draw(image, 0, 0, 0, u / image:getWidth(), v / image:getHeight())
  end)

  data.media.shaders.horizontalBlur:send('amount', .0016)
  data.media.shaders.verticalBlur:send('amount', .0016 * u / v)
  for i = 1, 3 do
    g.setShader(data.media.shaders.horizontalBlur)
    self.workingCanvas:renderTo(function()
      g.draw(self.background1)
    end)
    g.setShader(data.media.shaders.verticalBlur)
    self.background1:renderTo(function()
      g.draw(self.workingCanvas)
    end)
  end

  g.setShader()

  self.backgroundAlpha = 0
end

function Menu:drawBackground()
  local u, v = self.u, self.v
  local backgroundAlpha = math.lerp(self.prevBackgroundAlpha, self.backgroundAlpha, tickDelta / tickRate)
  g.setColor(255, 255, 255)
  g.draw(self.background2, 0, 0)
  g.setColor(255, 255, 255, backgroundAlpha * 255)
  g.draw(self.background1, 0, 0)

  g.setColor(0, 0, 0, 50)
  g.rectangle('fill', 0, 0, u, v)

  if self.page ~= 'start' then
    g.setColor(255, 255, 255)
    self.animations.muju:draw(u * .08, v * .75)
    for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
      local slot = self.animations.muju.spine.skeleton:findSlot(slot)
      slot.r, slot.g, slot.b = unpack(config.player.colors[self.user.color])
    end
  end
end

function Menu:initAnimations()
  self.animations = {}
  self.animations.muju = data.animation.muju({scale = .8, default = 'resurrect'})
  self.animations.muju.flipped = true
  self.animations.muju:on('complete', function(data)
    if data.state.name == 'resurrect' then self.animations.muju:set('idle', {force = true}) end
  end)

  self.animations.muju:on('event', function(data)
    if data.data.name == 'flor' then
      self:startGame()
    end
  end)

  -- TODO use a loop ya broad
  self.animations.thuju = data.animation.thuju({scale = .35})
  self.animations.bruju = data.animation.bruju({scale = .8})
  self.animations.buju = data.animation.buju({scale = .8})

  self.animations.thuju:on('complete', function() self.animations.thuju:set('idle', {force = true}) end)
  self.animations.bruju:on('complete', function() self.animations.bruju:set('idle', {force = true}) end)
  self.animations.buju:on('complete', function() self.animations.buju:set('idle', {force = true}) end)
end

function Menu:drawButton(text, x, y, w, h)

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

  if hover then
    if not self.buttonHoverActive then
      self.buttonHoverX = mx
      self.buttonHoverY = my
      local d = math.distance
      self.buttonHoverDistance = math.max(d(mx, my, x, y), d(mx, my, x + w, y), d(mx, my, x, y + h), d(mx, my, x + w, y + h))
    end

    g.setColor(255, 255, 255)
    g.setStencil(function()
      local y = active and y + diff * yscale or y
      local h = active and h - diff * yscale or h
      g.rectangle('fill', x, y, w, h)
    end)

    local factor = math.lerp(self.prevButtonHoverFactor, self.buttonHoverFactor, tickDelta / tickRate)
    g.setColor(255, 255, 255, 20)
    g.setBlendMode('additive')
    g.circle('fill', self.buttonHoverX, self.buttonHoverY, factor * self.buttonHoverDistance)
    g.setBlendMode('alpha')

    g.setStencil()

    self.buttonHoverActive = true
  else
    self.buttonHoverActive = false
  end

  -- Text
  if active then y = y + diff * yscale end
  g.setFont('mesmerize', h * .55)
  g.setColor(0, 0, 0, 100)
  g.printCenter(text, x + w / 2 + 1, y + (h - diff * yscale) / 2 + 1)
  g.setColor(255, 255, 255)
  g.printCenter(text, x + w / 2, y + (h - diff * yscale) / 2)
end
