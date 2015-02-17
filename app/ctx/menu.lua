local tween = require 'lib/deps/tween/tween'
local g = love.graphics

Menu = class()
Menu.started = false

function Menu:load(selectedBiome, options)
  data.load()

  -- Initialize options
  if not love.filesystem.exists('save/options.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/options.json', json.encode(config.defaultOptions))
  end
  local str = love.filesystem.read('save/options.json')
  self.options = options or json.decode(str)
  self.options = self.options or table.copy(config.defaultOptions)

  self.virtualCursor = VirtualCursor()
  self.gooey = Gooey()
  self.start = MenuStart()
  self.choose = MenuChoose()
  self.main = MenuMain()
  self.optionsPane = MenuOptions()

  -- Initialize user
  if not love.filesystem.exists('save/user.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(config.defaultUser))
    self.page = 'choose'
  end
  local str = love.filesystem.read('save/user.json')
  self.user = json.decode(str)
  self.user.deckSlots = 3
  saveUser(self.user)

  self.cursor = Cursor()
  self.sound = Sound()
  self.menuSounds = self.sound:loop('riteOfPassage')
  if ctx.options and ctx.options.mute then self.sound:setMute(ctx.options.mute) end

  self.u, self.v = love.graphics.getDimensions()
  self.tooltip = Tooltip()

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

  if self.page ~= 'start' then self:refreshBackground() end

  Menu.started = true

  self.main.selectedBiome = selectedBiome or self.main.selectedBiome

  love.keyboard.setKeyRepeat(true)
end

function Menu:update()
  self.cursor:update()
  self.tooltip:update()
  self.gooey:update()

  self.prevBackgroundAlpha = self.backgroundAlpha
  self.backgroundAlpha = math.lerp(self.backgroundAlpha, 1, math.min(8 * tickRate, 1))

  self.start:update()
  self.choose:update()
  self.main:update()
  self.optionsPane:update()

  self.virtualCursor:update()
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
    if self.page ~= 'start' then self:drawBackground() end
    self.choose:draw()
    self.main:draw()
  end)

  g.setColor(255, 255, 255)
  g.draw(self.screenCanvas)

  self.optionsPane:draw()

  self.tooltip:draw()
end

function Menu:keypressed(key)
  local consumed = self.main:keypressed(key)
  self.start:keypressed(key)
  self.choose:keypressed(key)
  self.optionsPane:keypressed(key)

  if consumed then return end

  if key == 'm' then
    self.options.mute = not self.options.mute
    self.sound:setMute(self.options.mute)
    saveOptions(self.options)
    self.optionsPane.refreshControls()
  elseif key == 'escape' then love.event.quit()
  elseif key == 'x' and love.keyboard.isDown('lctrl') and love.keyboard.isDown('lshift') then
    love.filesystem.remove('save/user.json')
    love.filesystem.remove('save/options.json')
    if ctx.menuSounds then ctx.menuSounds:stop() end
    Menu.started = false
    Context:remove(ctx)
    Context:add(Menu)
  elseif key == 't' then
    self:startGame({tutorial = true})
  end
end

function Menu:mousemoved(mx, my)
  self.tooltip:dirty()
end

function Menu:mousepressed(mx, my, b)
  self.gooey:mousepressed(mx, my, b)
  self.start:mousepressed(mx, my, b)
  self.choose:mousepressed(mx, my, b)
  self.main:mousepressed(mx, my, b)
  self.optionsPane:mousepressed(mx, my, b)
end

function Menu:mousereleased(mx, my, b)
  self.gooey:mousereleased(mx, my, b)
  self.start:mousereleased(mx, my, b)
  self.choose:mousereleased(mx, my, b)
  self.main:mousereleased(mx, my, b)
end

function Menu:gamepadpressed(gamepad, button)
  if button == 'a' then
    local x, y = love.mouse.getPosition()
    self:mousepressed(x, y, 'l')
  else
    self.start:gamepadpressed(gamepad, button)
    self.main:gamepadpressed(gamepad, button)
    self.optionsPane:gamepadpressed(gamepad, button)
  end
end

function Menu:gamepadreleased(gamepad, button)
  if button == 'a' then
    local x, y = love.mouse.getPosition()
    self:mousereleased(x, y, 'l')
  end
end

function Menu:gamepadaxis(...)
  self.optionsPane:gamepadaxis(...)
end

function Menu:textinput(char)
  self.choose:textinput(char)
end

function Menu:resize()
  self.u, self.v = g.getDimensions()
  self.background1 = g.newCanvas(self.u, self.v)
  self.background2 = g.newCanvas(self.u, self.v)
  self.workingCanvas = g.newCanvas(self.u, self.v)
  self.unitCanvas = g.newCanvas(400, 400)
  self.screenCanvas = g.newCanvas(self.u, self.v)

  self.gooey:resize()
  self.start:resize()
  self.choose:resize()
  self.main:resize()
  if self.optionsPane then self.optionsPane:resize() end
  self.canvas = g.newCanvas(u, v)
  self.workingCanvas = g.newCanvas(u, v)
  self:refreshBackground()
end

function Menu:startGame(options)
  if #self.user.deck.minions == 0 then return end
  if self.menuSounds then self.menuSounds:stop() end
  Context:remove(ctx)
  Context:add(Game, self.user, self.options, config.biomeOrder[self.main.selectedBiome], options and options.tutorial)
end

function Menu:refreshBackground()
  local u, v = self.u, self.v

  if not self.background1 or not self.background2 then return end

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
    buju = .4,
    kuju = .5
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
