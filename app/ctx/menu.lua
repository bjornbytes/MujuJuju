local tween = require 'lib/deps/tween/tween'
local g = love.graphics

Menu = class()

function Menu:load(selectedBiome)
	self.sound = Sound()
	self.menuSounds = self.sound:loop('menu')
	love.mouse.setCursor(love.mouse.newCursor('media/graphics/cursor.png'))

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    starters = function()
      local u, v = love.graphics.getDimensions()
      local minions = config.starters
      local size = .2 * v
      local inc = (size * 2) + .1 * v
      local x = u * .5 - inc * ((#minions - 1) / 2)
      local y = .6 * v
      local res = {}
      for i = 1, #minions do
        table.insert(res, {x, y, size / 2})
        x = x + inc
      end
      return res
    end,

    deck = function()
      local u, v = love.graphics.getDimensions()
      local size = .2 * v
      local inc = size + .2 * v
      local runeSize = .04 * v
      local runeInc = runeSize + .06 * v
      local x = u * .3 - inc * ((#self.user.deck.minions - 1) / 2)
      local y = .45 * v
      local runey = y - .15 * v
      local res = {}
      for i = 1, #self.user.deck.minions do
        table.insert(res, {x, y, size / 2, {}})
        local runex = x - (runeInc * (3 - 1) / 2)
        for i = 1, 3 do
          table.insert(res[#res][4], {runex, runey, runeSize})
          runex = runex + runeInc
        end
        x = x + inc
      end
      return res
    end,

    gutterRunes = function()
      local u, v = love.graphics.getDimensions()
      local size = .08 * v
      local inc = size + .01 * v
      local x = u * .19
      local ox = x
      local y = v * .675
      local res = {}
      for i = 1, 21 do
        table.insert(res, {x, y, size, size})
        x = x + inc
        if i % 7 == 0 then y = y + inc x = ox end
      end
      return res
    end,

    gutterRunesLabel = function()
      local u, v = ctx.u, ctx.v
      return {u * .19, v * .675 - v * .015 - v * .04}
    end,

    gutterRunesFrame = function()
      local u, v = ctx.u, ctx.v
      local label = self.geometry.gutterRunesLabel
      local x = label[1] - v * .02
      local y = label[2] - v * .01
      local w = u * .36 + v * .02
      local h = v * .34
      return {x, y, w, h}
    end,

    gutterMinions = function()
      local u, v = love.graphics.getDimensions()
      local r = .04 * v
      local inc = (r * 2) + .01 * v
      local x = self.popup.x
      local y = self.popup.y
      local res = {}
      for i = 1, #ctx.user.minions do
        table.insert(res, {x, y, r})
        x = x + inc
      end
      return res
    end,

    biomes = function()
      local u, v = love.graphics.getDimensions()
      local biomeDisplay = math.lerp(self.prevBiomeDisplay, self.biomeDisplay, tickDelta / tickRate)
      local width = .3 * v
      local height = width * .75
      local inc = width + .1 * v
      local x = u * .8
      local y = .3 * v
      local res = {}
      for i = 1, #config.biomeOrder do
        local offset = (inc * (biomeDisplay - i))
        local yoffset = (inc * (biomeDisplay - i) ^ 4)
        table.insert(res, {x - width / 2 - offset, y + yoffset, width, height})
      end
      return res
    end,

    play = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.gutterRunesFrame
      local w, h = .2 * u, .13 * v
      local midx = (.6 + (.4 / 2)) * u
      return {midx - w / 2, frame[2] + frame[4] - h, w, h}
    end
  }

  if not love.filesystem.exists('save/user.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(config.defaultUser))
  end

  local str = love.filesystem.read('save/user.json')
  self.user = json.decode(str)

  if not self.user.deck or #self.user.deck.minions == 0 then
    self.choosing = true
  end

  self.selectedBiome = selectedBiome or 1
  self.biomeDisplay = self.selectedBiome
  self.prevBiomeDisplay = self.biomeDisplay

  self.u, self.v = love.graphics.getDimensions()
  self.tooltip = Tooltip()

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

  self.animations.thuju = data.animation.thuju({scale = .35})
  self.animations.bruju = data.animation.bruju({scale = .8})

  self.animations.thuju:on('complete', function() self.animations.thuju:set('idle', {force = true}) end)
  self.animations.bruju:on('complete', function() self.animations.bruju:set('idle', {force = true}) end)

  self.popup = {
    x = nil,
    y = nil,
    active = false,
    time = 0,
    prevTime = 0,
    maxTime = .25,
    factor = {value = 0},
  }

  self.popup.tween = tween.new(.25, self.popup.factor, {value = 1}, 'inOutBack')

  self.backgroundAlpha = 0
  self.prevBackgroundAlpha = self.backgroundAlpha
  self.background1 = g.newCanvas(self.u, self.v)
  self.background2 = g.newCanvas(self.u, self.v)
  self.workingCanvas = g.newCanvas(self.u, self.v)
  self.unitCanvas = g.newCanvas(400, 400)
  self:refreshBackground()
end

function Menu:update()
  self.prevBiomeDisplay = self.biomeDisplay
  self.biomeDisplay = math.lerp(self.biomeDisplay, self.selectedBiome, math.min(10 * tickRate, 1))
  if math.abs(self.biomeDisplay - self.selectedBiome) > .01 then self.geometry.biomes = nil end

  self.prevBackgroundAlpha = self.backgroundAlpha
  self.backgroundAlpha = math.lerp(self.backgroundAlpha, 1, math.min(8 * tickRate, 1))

  self.popup.prevTime = self.popup.time
  if self.popup.active then self.popup.time = math.min(self.popup.time + tickRate, self.popup.maxTime)
  else self.popup.time = math.max(self.popup.time - tickRate, 0) end

  self.tooltip:update()
  
  local mx, my = love.mouse.getPosition()
  if self.choosing then
    local minions = self.geometry.starters
    for i = 1, #minions do
      if math.insideCircle(mx, my, unpack(minions[i])) then
        self.tooltip:setUnitTooltip(config.starters[i])
        break
      end
    end
  else
    local deck = self.geometry.deck
    for i = 1, #deck do
      local code = self.user.deck.minions[i]
      local x, y, r, runes = unpack(deck[i])

      if math.insideCircle(mx, my, x, y, r) then
        self.tooltip:setUnitTooltip(code)
        break
      else
        for j = 1, #runes do
          if self.user.deck.runes[i] and self.user.deck.runes[i][j] and math.insideCircle(mx, my, unpack(runes[j])) then
            self.tooltip:setRuneTooltip(self.user.deck.runes[i][j])
            break
          end
        end
      end
    end

    local gutterRunes = self.geometry.gutterRunes
    for i = 1, #gutterRunes do
      if self.user.runes[i] and math.inside(mx, my, unpack(gutterRunes[i])) then
        self.tooltip:setRuneTooltip(self.user.runes[i])
        break
      end
    end

    --[[local gutterMinions = self.geometry.gutterMinions
    for i = 1, #gutterMinions do
      local code = self.user.minions[i]
      local x, y, r = unpack(gutterMinions[i])

      if math.insideCircle(mx, my, x, y, r) then
        self.tooltip:setUnitTooltip(code)
        break
      end
    end]]
  end
end

function Menu:draw()
  local u, v = love.graphics.getDimensions()
  g.setColor(255, 255, 255)

  if not self.firstFrame then
    delta = 0
    self.firstFrame = true
  end

  --[=[if self.choosing then
    g.setFont('inglobalb', .08 * v)
    local str = 'Welcome to Muju Juju'
    g.print(str, .5 * u - g.getFont():getWidth(str) / 2, 2)
    local str = 'Choose your minion'
    g.print(str, .5 * u - g.getFont():getWidth(str) / 2, .2 * v)

    local minions = self.geometry.starters
    for i = 1, #minions do
      local x, y, r = unpack(minions[i])
      local image = data.media.graphics.unit.portrait[config.starters[i]]
      local scale = (r * 2) / image:getWidth()
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  else
    local deck = self.geometry.deck
    g.setColor(255, 255, 255)
    for i = 1, #deck do
      local x, y, r, runes = unpack(deck[i])
      local image = data.media.graphics.unit.portrait[self.user.deck.minions[i]]
      local scale = (r * 2) / image:getWidth()
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      for j = 1, #runes do
        local x, y, r = unpack(runes[j])
        if self.user.deck.runes[i] and self.user.deck.runes[i][j] then
          g.setColor(100, 100, 100)
        g.circle('fill', x, y, r)
        end
        g.setColor(255, 255, 255)
        g.circle('line', x, y, r)
      end
    end

    local biomes = self.geometry.biomes
    for i = 1, #biomes do
      local biome = config.biomeOrder[i]
      local x, y, w, h = unpack(biomes[i])
      if self.selectedBiome == i then g.setColor(255, 255, 255)
      else g.setColor(255, 255, 255, 100) end
      g.rectangle('fill', x, y, w, h)
      if table.has(self.user.biomes, biome) then g.setColor(0, 255, 0)
      else g.setColor(255, 0, 0) end
      g.rectangle('line', x + .5, y + .5, w, h)
      g.setColor(0, 0, 0)
      g.setFont('pixel', 8)
      g.printCenter(config.biomes[biome].name, x + w / 2, y + h / 2)
      g.setColor(255, 255, 255)
      local minutes = math.floor((self.user.highscores[biome] or 0) / 60)
      local seconds = self.user.highscores[biome] % 60
      local time = string.format('%02d:%02d', minutes, seconds)
      g.printCenter('highscore: ' .. time, x + w / 2, y + h + 16)
    end

    g.setColor(255, 255, 255)
    local gutterRunes = self.geometry.gutterRunes
    for i = 1, #gutterRunes do
      g.circle('line', unpack(gutterRunes[i]))
    end

    local gutterMinions = self.geometry.gutterMinions
    for i = 1, #gutterMinions do
      local x, y, r = unpack(gutterMinions[i])
      local image = data.media.graphics.unit.portrait[self.user.minions[i]]
      local scale = (r * 2) / image:getWidth()
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  end]=]

  local backgroundAlpha = math.lerp(self.prevBackgroundAlpha, self.backgroundAlpha, tickDelta / tickRate)
  g.setColor(255, 255, 255)
  g.draw(self.background2, 0, 0)
  g.setColor(255, 255, 255, backgroundAlpha * 255)
  g.draw(self.background1, 0, 0)

  g.setColor(0, 0, 0, 50)
  g.rectangle('fill', 0, 0, u, v)

  g.setColor(255, 255, 255)
  --g.line(u * .6, 0, u * .6, v)
  self.animations.muju:draw(u * .08, v * .75)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    self.animations.muju.spine.skeleton:findSlot(slot).r = .5
    self.animations.muju.spine.skeleton:findSlot(slot).g = 0
    self.animations.muju.spine.skeleton:findSlot(slot).b = 1
  end

  local biomeDisplay = math.lerp(self.prevBiomeDisplay, self.biomeDisplay, tickDelta / tickRate)
  local biomes = self.geometry.biomes
  for i = 1, #biomes do
    local biome = config.biomeOrder[i]
    local x, y, w, h = unpack(biomes[i])
    local alpha = 255 - (math.min(math.abs(biomeDisplay - i), 1.25) * (255 / 1.25))
    if self.selectedBiome == i then g.setColor(255, 255, 255, alpha)
    else g.setColor(255, 255, 255, alpha) end
    g.rectangle('fill', x, y, w, h)
    if table.has(self.user.biomes, biome) then g.setColor(0, 255, 0, alpha)
    else g.setColor(255, 0, 0, alpha) end
    g.rectangle('line', x + .5, y + .5, w, h)
    g.setColor(0, 0, 0, alpha)
    g.setFont('pixel', 8)
    g.printCenter(config.biomes[biome].name, x + w / 2, y + h / 2)
    g.setColor(255, 255, 255, alpha)
    local minutes = math.floor((self.user.highscores[biome] or 0) / 60)
    local seconds = self.user.highscores[biome] % 60
    local time = string.format('%02d:%02d', minutes, seconds)
    g.printCenter('highscore: ' .. time, x + w / 2, y + h + 16)
  end

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', unpack(self.geometry.gutterRunesFrame))

  g.setColor(255, 255, 255)
  local gutterRunes = self.geometry.gutterRunes
  for i = 1, #gutterRunes do
    local x, y, w, h = unpack(gutterRunes[i])
    local rune = self.user.runes[i]
    local image = data.media.graphics.hud.frame
    local scale = w / image:getWidth()
    g.setColor(255, 255, 255)
    g.draw(image, x, y, 0, scale, scale)

    if rune then
      
      -- Stone
      local image = data.media.graphics.runes['bg' .. rune.background:capitalize()]
      local scale = (h - v * .02) / image:getHeight()
      g.setColor(255, 255, 255)
      g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      -- Rune
      local image = data.media.graphics.runes[rune.image]
      local scale = ((h - v * .02) - .016 * v) / image:getHeight()
      g.setColor(config.runes.colors[rune.color])
      g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  end

  g.setFont('mesmerize', v * .04)
  local x, y = unpack(self.geometry.gutterRunesLabel)
  g.print('Runes', x, y)

  local deck = self.geometry.deck
  g.setColor(255, 255, 255)
  for i = 1, #deck do
    local code = self.user.deck.minions[i]
    local x, y, r, runes = unpack(deck[i])
    local cw, ch = self.unitCanvas:getDimensions()
    self.unitCanvas:clear(0, 0, 0, 0)
    self.unitCanvas:renderTo(function()
      self.animations[code]:draw(cw / 2, ch / 2)
    end)
    g.draw(self.unitCanvas, x, y, 0, 1, 1, cw / 2, ch / 2)

    for j = 1, #runes do
      local x, y, r = unpack(runes[j])
      if self.user.deck.runes[i] and self.user.deck.runes[i][j] then
        g.setColor(100, 100, 100)
      g.circle('fill', x, y, r)
      end
      g.setColor(255, 255, 255)
      g.circle('line', x, y, r)
    end
  end

  g.setColor(0, 0, 0, 255)
  g.rectangle('fill', unpack(self.geometry.play))

  if self.popup.time > 0 then
    local factor, t = self:getPopupFactor()
    local popupAlpha = (t / self.popup.maxTime) ^ 3
    g.setColor(0, 0, 0, 100 * popupAlpha)
    g.rectangle('fill', 0, 0, u, v)
    
    local w, h = math.max(u * .4 * factor, 0), math.max(v * .25 * factor, 0)
    local x, y = self.popup.x - w / 2, self.popup.y - h / 2
    g.setColor(30, 50, 70, 240 * popupAlpha)
    g.rectangle('fill', x, y, w, h)
    g.setColor(10, 30, 50, 255 * popupAlpha)
    g.rectangle('line', x, y, w, h)

    local gutterMinions = self.geometry.gutterMinions
    for i = 1, #gutterMinions do
      local code = self.user.minions[i]
      local x, y, r = unpack(gutterMinions[i])
      local cw, ch = self.unitCanvas:getDimensions()
      self.unitCanvas:clear(0, 0, 0, 0)
      self.unitCanvas:renderTo(function()
        self.animations[code]:draw(cw / 2, ch / 2)
      end)
      g.setColor(255, 255, 255, 255 * popupAlpha)
      g.draw(self.unitCanvas, x, y, 0, 1, 1, cw / 2, ch / 2)
    end
  end

  self.tooltip:draw()
end

function Menu:keypressed(key)
  if self.choosing then return end
	if key == 'return' and table.has(self.user.biomes, config.biomeOrder[self.selectedBiome]) then
    self.animations.muju:set('death')
  elseif key == 'left' then
    self.selectedBiome = self.selectedBiome - 1
    if self.selectedBiome <= 0 then self.selectedBiome = #ctx.user.biomes end
    self:refreshBackground()
  elseif key == 'right' then
    self.selectedBiome = self.selectedBiome + 1
    if self.selectedBiome >= #ctx.user.biomes + 1 then self.selectedBiome = 1 end
    self:refreshBackground()
  elseif key == 'x' and love.keyboard.isDown('lctrl') then
    love.filesystem.remove('save/user.json')
    if self.menuSounds then self.menuSounds:stop() end
    Context:remove(ctx)
    Context:add(Menu)
  elseif key:match('%d') and not self.choosing then
    local index = tonumber(key)
    if index >= 1 and index <= #self.user.deck.minions then
      self.user.deck.runes[index] = self.user.deck.runes[index] or {}
      if #self.user.deck.runes[index] < 3 then
        local gutterRunes = self.geometry.gutterRunes
        local mx, my = love.mouse.getPosition()
        for i = 1, #gutterRunes do
          if #ctx.user.deck.runes[index] < 3 and math.insideCircle(mx, my, unpack(gutterRunes[i])) then
            table.insert(ctx.user.deck.runes[index], self.user.runes[i])
            table.remove(self.user.runes, i)
            table.clear(self.geometry)
            saveUser(self.user)
          end
        end
      end
    end
  end

  if key == 'p' then
    self.popup.active = not self.popup.active
    if self.popup.active then
      self.popup.x = love.mouse.getX()
      self.popup.y = love.mouse.getY()
      self.geometry.gutterMinions = nil
    end
  end
end

function Menu:keyreleased(key)
  
end

function Menu:mousepressed(mx, my, b)
  if self.choosing then
    if b == 'l' then
      local minions = self.geometry.starters
      for i = 1, #minions do
        local x, y, r = unpack(minions[i])
        if math.distance(mx, my, x, y) < r then
          self.user.minions = self.user.minions or {}
          self.user.deck.minions = {config.starters[i]}
          saveUser(self.user)
          self.choosing = false
        end
      end
    end
  else
    if b == 'l' then
      local play = self.geometry.play
      if math.inside(mx, my, unpack(self.geometry.play)) then
        self.animations.muju:set('death')
      end

      if self.popup.active then
        local gutterMinions = self.geometry.gutterMinions
        for i = 1, #gutterMinions do
          if #ctx.user.deck.minions < 3 and math.insideCircle(mx, my, unpack(gutterMinions[i])) then
            self.animations[self.user.minions[i]]:set('spawn')
            table.insert(ctx.user.deck.minions, self.user.minions[i])
            table.remove(self.user.minions, i)
            self.user.deck.runes[#ctx.user.deck.minions] = {}
            self.popup.active = false
            table.clear(self.geometry)
            saveUser(self.user)
          end
        end
      end
    elseif b == 'r' then
      local deck = self.geometry.deck
      for i = 1, #deck do
        local x, y, r, runes = unpack(deck[i])
        if self.user.deck.minions[i] and math.insideCircle(mx, my, x, y, r) then
          local code = self.user.deck.minions[i]
          table.insert(self.user.minions, code)
          while self.user.deck.runes[i] and #self.user.deck.runes[i] > 0 do
            table.insert(self.user.runes, self.user.deck.runes[i][1])
            table.remove(self.user.deck.runes[i], 1)
          end
          self.user.deck.runes[i] = nil
          table.remove(self.user.deck.minions, i)
          table.clear(self.geometry)
          saveUser(self.user)
          break
        else
          for j = 1, #runes do
            if self.user.deck.runes[i] and self.user.deck.runes[i][j] and math.insideCircle(mx, my, unpack(runes[j])) then
              table.insert(self.user.runes, self.user.deck.runes[i][j])
              table.remove(self.user.deck.runes[i], j)
              table.clear(self.geometry)
              saveUser(self.user)
              break
            end
          end
        end
      end

      local runes = self.geometry.gutterRunes
      for i = 1, #runes do
        if math.insideCircle(mx, my, unpack(runes[i])) then
          table.remove(self.user.runes, i)
          table.clear(self.geometry)
          saveUser(self.user)
          break
        end
      end
    end
  end
end

function Menu:mousereleased(x, y, b)
  --
end

function Menu:startGame()
  if self.menuSounds then self.menuSounds:stop() end
  Context:remove(ctx)
  Context:add(Game, self.user, config.biomeOrder[self.selectedBiome])
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
    local image = data.media.graphics.map[config.biomeOrder[self.selectedBiome]]
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

function Menu:getPopupFactor()
  local t = math.lerp(self.popup.prevTime, self.popup.time, tickDelta / tickRate)
  self.popup.tween:set(t)
  return self.popup.factor.value, t
end
