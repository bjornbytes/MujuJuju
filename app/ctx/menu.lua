local tween = require 'lib/deps/tween/tween'
local g = love.graphics

Menu = class()
Menu.started = false

function Menu:load(selectedBiome)
  data.load()
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
      local runeSize = .08 * v
      local runeInc = runeSize + .02 * v
      local x = u * .3 - inc * ((#self.user.deck.minions - 1) / 2)
      local y = .35 * v
      local runey = y - .15 * v
      local res = {}
      for i = 1, #self.user.deck.minions do
        table.insert(res, {x, y, size / 2, {}})
        local runex = x - (runeInc * (3 - 1) / 2)
        for i = 1, 3 do
          table.insert(res[#res][4], {runex - runeSize / 2, runey - runeSize / 2, runeSize, runeSize})
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
      local r = .08 * v
      local inc = (r * 2) + .02 * v
      local x = self.popup.x - (inc * (#ctx.user.minions - 1 ) / 2)
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
      local y = .25 * v
      local res = {}
      for i = 1, #config.biomeOrder do
        local offset = (inc * (biomeDisplay - i))
        local yoffset = (inc * (biomeDisplay - i) ^ 4)
        table.insert(res, {x - width / 2 - offset, y + yoffset, width, height})
      end
      return res
    end,

    biomeArrows = function()
      local u, v = love.graphics.getDimensions()
      local image = data.media.graphics.menu.arrow
      local scale = v * .04 / image:getWidth()
      local w = .3 * v
      local h = w * .75
      local x = u * .8 - w / 2
      local y = .25 * v
      return {{x - v * .06, y + h / 2}, {x + w + v * .06, y + h / 2}}
    end,

    play = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.gutterRunesFrame
      local w, h = .2 * u, .13 * v
      local midx = (.6 + (.4 / 2)) * u
      return {midx - w / 2, frame[2] + frame[4] - h - v * .05, w, h}
    end
  }

  if not love.filesystem.exists('save/user.json') then
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(config.defaultUser))
  end

  local str = love.filesystem.read('save/user.json')
  self.user = json.decode(str)

  self.starting = not Menu.started
  self.startingAlpha = 1
  self.startingScale = 0
  self.startingTween = tween.new(.5, self, {startingScale = 1}, 'outBack')
  Menu.started = true
  if not self.starting then
    self.startingAlpha = 0
    self.startingScale = 1
  end

  if not self.user.deck or #self.user.deck.minions == 0 then
    self.choosing = true
  end

  self.selectedBiome = selectedBiome or 1
  self.biomeDisplay = self.selectedBiome
  self.prevBiomeDisplay = self.biomeDisplay
  self.biomeArrowScales = {}
  self.prevBiomeArrowScales = {}

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
  self.animations.buju = data.animation.buju({scale = .8})

  self.animations.thuju:on('complete', function() self.animations.thuju:set('idle', {force = true}) end)
  self.animations.bruju:on('complete', function() self.animations.bruju:set('idle', {force = true}) end)

  self.popup = {
    x = self.u * .5,
    y = self.v * .5,
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
  if not self.starting then
    self:refreshBackground()
  end
end

function Menu:update()
  if self.starting then

    return
  end

  self.startingAlpha = math.max(self.startingAlpha - tickRate, 0)

  local mx, my = love.mouse.getPosition()

  self.tooltip:update()

  if self.popup.time > 0 or self.popup.active then
    self.popup.prevTime = self.popup.time
    if self.popup.active then self.popup.time = math.min(self.popup.time + tickRate, self.popup.maxTime)
    else self.popup.time = math.max(self.popup.time - tickRate, 0) end

    local gutterMinions = self.geometry.gutterMinions
    for i = 1, #gutterMinions do
      local code = self.user.minions[i]
      local x, y, r = unpack(gutterMinions[i])

      if math.insideCircle(mx, my, x, y, r) then
        self.tooltip:setUnitTooltip(code)
        break
      end
    end
    return
  end
    
  self.prevBiomeDisplay = self.biomeDisplay
  self.biomeDisplay = math.lerp(self.biomeDisplay, self.selectedBiome, math.min(10 * tickRate, 1))
  if math.abs(self.biomeDisplay - self.selectedBiome) > .001 then self.geometry.biomes = nil end

  self.prevBackgroundAlpha = self.backgroundAlpha
  self.backgroundAlpha = math.lerp(self.backgroundAlpha, 1, math.min(8 * tickRate, 1))
  
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
          if self.user.deck.runes[i] and self.user.deck.runes[i][j] and math.inside(mx, my, unpack(runes[j])) then
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

    local image = data.media.graphics.menu.arrow
    local w = self.v * .04
    for i = 1, 2 do
      self.prevBiomeArrowScales[i] = self.biomeArrowScales[i] or 1
      local x, y = unpack(self.geometry.biomeArrows[i])
      local hover = math.inside(mx, my, x - w / 2, y - w / 2, w, w)
      self.biomeArrowScales[i] = math.lerp(self.biomeArrowScales[i] or 1, hover and 1.5 or 1, 10 * tickRate)
    end
  end
end

function Menu:draw()
  local u, v = love.graphics.getDimensions()

  self.frameIndex = self.frameIndex or 0
  self.frameIndex = self.frameIndex + 1
  if self.frameIndex < 3 then
    delta = 0
  end

  if self.startingAlpha > 0 then
    self.startingTween:update(delta)
    local factor = self.startingScale

    g.setColor(255, 255, 255)
    local image = data.media.graphics.menu.titlescreen
    local scale = math.min(u / image:getWidth(), v / image:getHeight())
    g.draw(image, 0, 0, 0, scale, scale)

    local image = data.media.graphics.menu.title
    local scale = v * .45 / image:getHeight()
    g.draw(image, u * .5, v * .3, 0, scale * factor, scale * factor, image:getWidth() / 2, image:getHeight() / 2)

    local image = data.media.graphics.menu.start
    local scale = u * .25 / image:getWidth()
    g.draw(image, u * .5, v * .7, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if self.starting then return end
  end

  local backgroundAlpha = math.lerp(self.prevBackgroundAlpha, self.backgroundAlpha, tickDelta / tickRate)
  g.setColor(255, 255, 255)
  g.draw(self.background2, 0, 0)
  g.setColor(255, 255, 255, backgroundAlpha * 255)
  g.draw(self.background1, 0, 0)

  g.setColor(0, 0, 0, 50)
  g.rectangle('fill', 0, 0, u, v)

  g.setColor(255, 255, 255)
  self.animations.muju:draw(u * .08, v * .75)
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    self.animations.muju.spine.skeleton:findSlot(slot).r = .5
    self.animations.muju.spine.skeleton:findSlot(slot).g = 0
    self.animations.muju.spine.skeleton:findSlot(slot).b = 1
  end

  if self.choosing then
    g.setColor(0, 0, 0, 100)
    g.rectangle('fill', u * .2, v * .33, u * .6, v * .42)

    g.setFont('mesmerize', .08 * v)
    local str = 'Choose your minion'
    g.setColor(0, 0, 0)
    g.print(str, .5 * u - g.getFont():getWidth(str) / 2 + 1, .35 * v + 1)
    g.setColor(255, 255, 255)
    g.print(str, .5 * u - g.getFont():getWidth(str) / 2, .35 * v)

    local minions = self.geometry.starters
    for i = 1, #minions do
      local code = config.starters[i]
      local x, y, r = unpack(minions[i])
      local cw, ch = self.unitCanvas:getDimensions()
      self.unitCanvas:clear(0, 0, 0, 0)
      self.unitCanvas:renderTo(function()
        self.animations[code]:draw(cw / 2, ch / 2)
      end)
      g.draw(self.unitCanvas, x, y, 0, 1, 1, cw / 2, ch / 2)
    end
    
    return self.tooltip:draw()
  end

  local biomeDisplay = math.lerp(self.prevBiomeDisplay, self.biomeDisplay, tickDelta / tickRate)
  local biomes = self.geometry.biomes
  for i = 1, #biomes do
    local biome = config.biomeOrder[i]
    local unlocked = table.has(ctx.user.biomes, config.biomeOrder[i])
    local x, y, w, h = unpack(biomes[i])
    local alpha = 255 - (math.min(math.abs(biomeDisplay - i), 1.35) * (255 / 1.35))
    if not unlocked then alpha = alpha * .5 end
    if self.selectedBiome == i then g.setColor(255, 255, 255, alpha)
    else g.setColor(255, 255, 255, alpha) end
    local image = data.media.graphics.menu[config.biomeOrder[i]]
    local scale = w / image:getWidth()
    g.draw(image, x, y, 0, scale, scale)

    if not unlocked then
      local lockImage = data.media.graphics.menu.lock
      local lockX = x + (w / 2) - (lockImage:getWidth() * scale) / 2
      local lockY = y + (h / 2) - (lockImage:getHeight() * scale) / 2
      if self.selectedBiome == i then g.setColor(255, 255, 255, 255)
      else g.setColor(255, 255, 255, alpha) end
      g.draw(data.media.graphics.menu.lock, lockX, lockY, 0, scale, scale)
    end

    local detailsAlpha = 255 - (math.min(math.abs(biomeDisplay - i), 1) * (255 / 1))
    if detailsAlpha > 1 then
      g.setFont('mesmerize', .06 * v)
      g.setColor(0, 0, 0, detailsAlpha)
      g.printCenter(config.biomes[biome].name, x + w / 2 + 1, .15 * v + 1)
      g.setColor(255, 255, 255, detailsAlpha)
      g.printCenter(config.biomes[biome].name, x + w / 2, .15 * v)

      local medalSize = v * .03
      local medalInc = (medalSize * 2 + (v * .02))
      local medalX = x + w / 2 - medalInc * (3 - 1) / 2
      local medalY = y + h + medalSize + (v * .05)
      for i, benchmark in ipairs({'bronze', 'silver', 'gold'}) do
        local achieved = self.user.highscores[biome] >= config.biomes[biome].benchmarks[benchmark]
        g.setColor(255, 255, 255, (achieved and 1 or .4) * detailsAlpha)
        local image = data.media.graphics.menu[benchmark]
        local scale = medalSize * 2 / image:getWidth() * (achieved and 1 or .8)
        g.draw(image, medalX, medalY, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
        medalX = medalX + medalInc
      end

      local minutes = math.floor((self.user.highscores[biome] or 0) / 60)
      local seconds = self.user.highscores[biome] % 60
      local time = string.format('%02d:%02d', minutes, seconds)
      g.setFont('mesmerize', .04 * v)
      g.setColor(0, 0, 0, detailsAlpha)
      g.printf('Best Time ' .. time, x + w / 2 - 100 + 1, medalY + medalSize + v * .04 + 1, 200, 'center')
      g.setColor(255, 255, 255, detailsAlpha)
      g.printf('Best Time ' .. time, x + w / 2 - 100, medalY + medalSize + v * .04, 200, 'center')
    end
  end

  local biomeArrows = self.geometry.biomeArrows
  local image = data.media.graphics.menu.arrow
  local scale = .04 * v / image:getWidth()
  for i = 1, 2 do
    local x, y = unpack(biomeArrows[i])
    local factor = math.lerp(self.prevBiomeArrowScales[i], self.biomeArrowScales[i], tickDelta / tickRate)
    g.setColor(255, 255, 255)
    g.draw(image, x, y, 0, scale * (i == 2 and -1 or 1) * factor, scale * factor, image:getWidth() / 2, image:getHeight() / 2)
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
      local scale = ((h - v * .02) - .02 * v) / image:getHeight()
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
      local x, y, w, h = unpack(runes[j])
      local rune = self.user.deck.runes[i] and self.user.deck.runes[i][j]
      local image = data.media.graphics.hud.frame
      local scale = w / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, x, y, 0, scale, scale)

      if self.user.deck.runes[i] and self.user.deck.runes[i][j] then
        local rune = self.user.deck.runes[i][j]

        -- Stone
        local image = data.media.graphics.runes['bg' .. rune.background:capitalize()]
        local scale = (h - v * .02) / image:getHeight()
        g.setColor(255, 255, 255)
        g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

        -- Rune
        local image = data.media.graphics.runes[rune.image]
        local scale = ((h - v * .02) - .02 * v) / image:getHeight()
        g.setColor(config.runes.colors[rune.color])
        g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      end
    end
  end

  g.setColor(255, 255, 255, 255)
  local x, y, w, h = unpack(self.geometry.play)
  local image = data.media.graphics.menu.play
  local scale = math.min(h / image:getHeight(), w / image:getWidth())
  g.draw(image, x + w / 2, y + h, 0, scale, scale, image:getWidth() / 2, image:getHeight())

  if self.popup.time > 0 then
    local factor, t = self:getPopupFactor()
    local popupAlpha = (t / self.popup.maxTime) ^ 3
    g.setColor(0, 0, 0, 150 * popupAlpha)
    g.rectangle('fill', 0, 0, u, v)
    
    local r = .08 * v
    local inc = (r * 2) + .02 * v
    local w, h = math.max((v * .1 + (#ctx.user.minions) * inc) * factor, 0), math.max(v * .25 * factor, 0)
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
      g.draw(self.unitCanvas, x, y, 0, .8 * factor, .75 * factor, cw / 2, ch / 2)
    end
  end

  self.tooltip:draw()
end

function Menu:keypressed(key)
  if self.starting then
    if key == 'return' then
      self:start()
    end
    return
  elseif self.choosing then
    return
  else
    if key == 'return' and table.has(self.user.biomes, config.biomeOrder[self.selectedBiome]) then
      self.animations.muju:set('death')
    elseif key == 'left' then self:previousBiome()
    elseif key == 'right' then self:nextBiome() 
    elseif key == 'x' and love.keyboard.isDown('lctrl') and love.keyboard.isDown('lshift') then
      love.filesystem.remove('save/user.json')
      if self.menuSounds then self.menuSounds:stop() end
      Menu.started = false
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
              break
            end
          end
        end
      end
    elseif key == 'p' then
      self.popup.active = not self.popup.active
    end
  end
end

function Menu:mousepressed(mx, my, b)
  if self.starting then
    local u, v = ctx.u, ctx.v
    local image = data.media.graphics.menu.start
    local w = u * .25
    local h = w * (image:getHeight() / image:getWidth())
    if math.inside(mx, my, u * .5 - w / 2, v * .7 - h / 2, w, h) then
      self:start()
    end
    return
  elseif self.choosing then
    if b == 'l' then
      local minions = self.geometry.starters
      for i = 1, #minions do
        local x, y, r = unpack(minions[i])
        if math.distance(mx, my, x, y) < r then
          self.user.minions = self.user.minions or {}
          self.user.deck.minions = {config.starters[i]}
          self.user.deck.runes[1] = {}
          saveUser(self.user)
          self.choosing = false
          self.animations.muju:set('summon')
          ctx.sound:play('summon2')
        end
      end
    end
    return
  else
    if b == 'l' then
      local play = self.geometry.play
      if math.inside(mx, my, unpack(self.geometry.play)) then
        self.animations.muju:set('death')
      end

      for i = 1, 2 do
        local width = self.v * .04
        local x, y = unpack(self.geometry.biomeArrows[i])
        if math.inside(mx, my, x - width / 2, y - width / 2, width, width) then
          if i == 1 then self:previousBiome()
          elseif i == 2 then self:nextBiome() end
        end
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
        if math.insideCircle(mx, my, x, y, r) then
          table.insert(self.user.minions, self.user.deck.minions[i])
          table.remove(self.user.deck.minions, i)
          saveUser(self.user)
          table.clear(self.geometry)
          break
        end
        for j = 1, #runes do
          if self.user.deck.runes[i] and self.user.deck.runes[i][j] and math.inside(mx, my, unpack(runes[j])) then
            table.insert(self.user.runes, self.user.deck.runes[i][j])
            table.remove(self.user.deck.runes[i], j)
            table.clear(self.geometry)
            saveUser(self.user)
            break
          end
        end
      end

      if love.keyboard.isDown('lshift') then
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

function Menu:previousBiome()
  self.selectedBiome = self.selectedBiome - 1
  if self.selectedBiome <= 0 then self.selectedBiome = #config.biomeOrder end
  self:refreshBackground()
end

function Menu:nextBiome()
  self.selectedBiome = self.selectedBiome + 1
  if self.selectedBiome >= #config.biomeOrder + 1 then self.selectedBiome = 1 end
  self:refreshBackground()
end

function Menu:start()
  self:refreshBackground()
  self.starting = false
end
