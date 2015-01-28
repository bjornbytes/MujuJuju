local tween = require 'lib/deps/tween/tween'
local g = love.graphics

Menu = class()
Menu.started = false

function Menu:load(selectedBiome, options)
  data.load()

  self.cursor = Cursor()
  self.sound = Sound()
  self.menuSounds = self.sound:loop('riteOfPassage')
  if options and options.muted then self.sound:mute() end

  if not love.filesystem.exists('save/user.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(config.defaultUser))
    self.page = 'choose'
  end

  local str = love.filesystem.read('save/user.json')
  self.user = json.decode(str)

  self.u, self.v = love.graphics.getDimensions()
  self.tooltip = Tooltip()
  self.button = Button()

  self:initAnimations()

  self.runeTransforms = {}
  self.prevRuneTransforms = {}
  table.each(self.user.runes, function(rune)
    self.runeTransforms[rune] = {}
    self.prevRuneTransforms[rune] = {}
  end)
  table.each(self.user.deck.runes, function(runes)
    table.each(runes, function(rune)
      self.runeTransforms[rune] = {}
      self.prevRuneTransforms[rune] = {}
    end)
  end)

  self.backgroundAlpha = 0
  self.prevBackgroundAlpha = self.backgroundAlpha
  self.background1 = g.newCanvas(self.u, self.v)
  self.background2 = g.newCanvas(self.u, self.v)
  self.workingCanvas = g.newCanvas(self.u, self.v)
  self.unitCanvas = g.newCanvas(400, 400)
  self.screenCanvas = g.newCanvas(self.u, self.v)

  self.page = self.page or (Menu.started and 'main' or 'start')

  self.start = MenuStart()
  self.choose = MenuChoose()
  self.main = MenuMain()
  self.options = MenuOptions()

  if self.page ~= 'start' then self:refreshBackground() end

  self.main.selectedBiome = selectedBiome or self.main.selectedBiome

  love.keyboard.setKeyRepeat(true)
end

function Menu:update()
  self.cursor:update()
  self.tooltip:update()
  self.button:update()

  self.prevBackgroundAlpha = self.backgroundAlpha
  self.backgroundAlpha = math.lerp(self.backgroundAlpha, 1, math.min(8 * tickRate, 1))

  self.start:update()
  self.choose:update()
  self.main:update()
  self.options:update()
end

function Menu:draw()
  self.frameIndex = self.frameIndex or 0
  self.frameIndex = self.frameIndex + 1
  if self.frameIndex < 3 then
    delta = 0
  end

  self.screenCanvas:clear(0, 0, 0, 0)
  self.screenCanvas:renderTo(function()
    self.start:draw()
    self:drawBackground()
    self.choose:draw()
    self.main:draw()
  end)

  g.setColor(255, 255, 255)
  g.draw(self.screenCanvas)

  self.options:draw()

  self.tooltip:draw()
end

function Menu:keypressed(key)
  self.start:keypressed(key)
  self.choose:keypressed(key)
  self.main:keypressed(key)
  self.options:keypressed(key)

  if key == 'm' then self.sound:mute()
  elseif key == 'escape' then love.event.quit() end
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
  if #self.user.deck.minions == 0 then return end
  if self.menuSounds then self.menuSounds:stop() end
  Context:remove(ctx)
  Context:add(Game, self.user, config.biomeOrder[self.main.selectedBiome], {muted = self.sound.muted})
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
    self.animations.muju:set('idle', {force = true})
  end)

  self.animations.muju:on('event', function(data)
    if data.data.name == 'flor' then
      self:startGame()
    end
  end)

  local scales = {
    thuju = .4,
    bruju = 1,
    buju = .4
  }

  self.animationTransforms = {}
  self.prevAnimationTransforms = {}

  for _, code in pairs(config.starters) do
    self.animations[code] = data.animation[code]({scale = scales[code]})
    self.animations[code]:on('complete', function() self.animations[code]:set('idle', {force = true}) end)
    self.animationTransforms[code] = {}
    self.prevAnimationTransforms[code] = {}
  end
end
