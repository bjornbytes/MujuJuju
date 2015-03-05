local tween = require 'lib/deps/tween/tween'
local g = love.graphics

Menu = class()

function Menu:load(options, systemOptions)
  data.load()

  -- Initialize UI
  self.u, self.v = love.graphics.getDimensions()
  self.virtualCursor = VirtualCursor()
  self.gooey = Gooey()

  -- Initialize pages
  self.start = MenuStart()
  self.select = MenuUser()
  self.choose = MenuChoose()
  self.campaign = MenuCampaign()

  -- Initialize options
  if not love.filesystem.exists('save/options.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/options.json', json.encode(config.defaultOptions))
  end
  local str = love.filesystem.read('save/options.json')
  self.options = systemOptions or json.decode(str)
  self.options = self.options or table.copy(config.defaultOptions)
  self.optionsPane = MenuOptions()

  -- Initialize sound
  self.sound = Sound(self.options)
  self.menuSounds = self.sound:loop('riteOfPassage')
  if ctx.options and ctx.options.mute then self.sound:setMute(ctx.options.mute) end

  -- Initialize uv and tooltip
  self.tooltip = Tooltip()

  self:initAnimations()

  -- Initialize backgrounds and canvases
  self.backgroundAlpha = 0
  self.prevBackgroundAlpha = self.backgroundAlpha
  self.background1 = g.newCanvas(self.u, self.v)
  self.background2 = g.newCanvas(self.u, self.v)
  self.workingCanvas = g.newCanvas(self.u, self.v)
  self.unitCanvas = g.newCanvas(400, 400)
  self.screenCanvas = g.newCanvas(self.u, self.v)

  self.campaign.selectedBiome = options and options.biome or self.campaign.selectedBiome
  self.user = options and options.user
  self.page = options and options.page or 'start'

  self:goto(self.page)

  if self.page ~= 'start' then self:refreshBackground() end

  love.keyboard.setKeyRepeat(true)
end

function Menu:update()
  -- Ensure that "Play" can't be clicked while options is open
  if self.optionsPane.active then self.campaign.play.disabled = true
  else self.campaign.play.disabled = false end

  self.tooltip:update()
  self.gooey:update()

  self.prevBackgroundAlpha = self.backgroundAlpha
  self.backgroundAlpha = math.lerp(self.backgroundAlpha, 1, math.min(8 * ls.tickrate, 1))

  self.start:update()
  self.select:update()
  self.choose:update()
  self.campaign:update()
  self.optionsPane:update()

  self.virtualCursor:update()
end

function Menu:draw()
  if ls.frame < 3 then
    ls.dt = 0
  end

  self.screenCanvas:clear(0, 0, 0, 0)
  self.screenCanvas:renderTo(function()
    self.start:draw()
    if self.page ~= 'start' then self:drawBackground() end
    self.select:draw()
    self.choose:draw()
    self.campaign:draw()
  end)

  g.setColor(255, 255, 255)
  g.draw(self.screenCanvas)

  self.optionsPane:draw()
  self.tooltip:draw()
end

function Menu:keypressed(key)
  if self.campaign:keypressed(key) then return end
  if self.optionsPane:keypressed(key) then return end
  if self.select:keypressed(key) then return end
  if self.choose:keypressed(key) then return end
  if self.start:keypressed(key) then return end

  if key == 'm' then
    self.options.mute = not self.options.mute
    self.sound:setMute(self.options.mute)
    saveOptions(self.options)
    self.optionsPane.refreshControls()
  elseif key == 'escape' then love.event.quit()
  elseif key == 'x' and love.keyboard.isDown('lctrl') and love.keyboard.isDown('lshift') then
    love.filesystem.remove('save/user.json')
    love.filesystem.remove('save/' .. ctx.user.name .. '/options.json')
    if ctx.menuSounds then ctx.menuSounds:stop() end
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
  if self.optionsPane:mousepressed(mx, my, b) then return end
  self.start:mousepressed(mx, my, b)
  self.choose:mousepressed(mx, my, b)
  self.campaign:mousepressed(mx, my, b)
end

function Menu:mousereleased(mx, my, b)
  self.gooey:mousereleased(mx, my, b)
  self.start:mousereleased(mx, my, b)
  self.campaign:mousereleased(mx, my, b)
end

function Menu:gamepadpressed(gamepad, button)
  if button == 'a' then
    local x, y = love.mouse.getPosition()
    self:mousepressed(x, y, 'l')
  else
    self.start:gamepadpressed(gamepad, button)
    self.campaign:gamepadpressed(gamepad, button)
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

  love.mouse.setCursor(love.mouse.newCursor('media/graphics/cursor' .. ((love.window.getPixelScale() == 2) and '' or '') .. '.png'))
  self.gooey:resize()
  self.start:resize()
  self.choose:resize()
  self.campaign:resize()
  self.select:resize()
  if self.optionsPane then self.optionsPane:resize() end
  self.canvas = g.newCanvas(u, v)
  self.workingCanvas = g.newCanvas(u, v)
  self:refreshBackground()
end

function Menu:startGame(options)
  if #self.user.deck.minions == 0 then return end
  if self.menuSounds then self.menuSounds:stop() end
  Context:remove(ctx)
  Context:add(Game, self.user, self.options, config.biomeOrder[self.campaign.selectedBiome], options and options.tutorial)
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
    local image = data.media.graphics.map[config.biomeOrder[self.campaign.selectedBiome]]
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
  local backgroundAlpha = math.lerp(self.prevBackgroundAlpha, self.backgroundAlpha, ls.accum / ls.tickrate)
  g.setColor(255, 255, 255)
  g.draw(self.background2, 0, 0)
  g.setColor(255, 255, 255, backgroundAlpha * 255)
  g.draw(self.background1, 0, 0)

  g.setColor(0, 0, 0, 50)
  g.rectangle('fill', 0, 0, u, v)
end

function Menu:initAnimations()
  self.animations = {}
  self.animations.muju = data.animation.muju({scale = 1, default = 'resurrect'})
  self.animations.muju.flipped = true
  self.animations.muju:on('complete', function(data)
    self.animations.muju:set('idle', {force = true})
  end)

  self.animations.muju:on('event', function(data)
    if data.data.name == 'flor' then
      self:startGame()
    end
  end)

  self.animationScales = {
    thuju = .4,
    bruju = 1,
    xuju = .4,
    kuju = .5
  }

  self.animationTransforms = {}
  self.prevAnimationTransforms = {}

  for _, code in pairs(config.starters) do
    self.animations[code] = data.animation[code]({scale = self.animationScales[code]})
    self.animations[code]:on('complete', function() self.animations[code]:set('idle', {force = true}) end)
    self.animationTransforms[code] = {}
    self.prevAnimationTransforms[code] = {}
  end
end

function Menu:goto(page)
  -- Deactivate the old page
  ctx[ctx.page].active = false
  f.exe(ctx[ctx.page].deactivate, ctx[ctx.page])

  -- Activate the new page
  ctx.page = page
  ctx[page].active = true
  f.exe(ctx[page].activate, ctx[page])
end
