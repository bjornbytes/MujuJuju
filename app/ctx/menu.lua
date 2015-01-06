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
      local x = u * .5 - inc * ((#self.user.deck.minions - 1) / 2)
      local y = .7 * v
      local runey = y + .15 * v
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
      local r = .04 * v
      local inc = r + .01 * v
      local x = inc
      local y = inc
      local res = {}
      for i = 1, #ctx.user.runes do
        table.insert(res, {x, y, r})
        x = x + inc
      end
      return res
    end,

    gutterMinions = function()
      local u, v = love.graphics.getDimensions()
      local r = .04 * v
      local inc = r + .01 * v
      local x = inc
      local y = inc * 3
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
      local x = u * .5
      local y = .3 * v
      local res = {}
      for i = 1, #config.biomeOrder do
        local offset = (inc * (biomeDisplay - i))
        table.insert(res, {x - width / 2 - offset, y, width, height})
      end
      return res
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
end

function Menu:update()
  self.prevBiomeDisplay = self.biomeDisplay
  self.biomeDisplay = math.lerp(self.biomeDisplay, self.selectedBiome, math.min(10 * tickRate, 1))
  if math.abs(self.biomeDisplay - self.selectedBiome) > .01 then self.geometry.biomes = nil end

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
      local x, y, r, runes = unpack(deck[i])
      if math.insideCircle(mx, my, x, y, r) then
        self.tooltip:setUnitTooltip(self.user.deck.minions[i])
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
      if math.insideCircle(mx, my, unpack(gutterRunes[i])) then
        self.tooltip:setRuneTooltip(self.user.runes[i])
        break
      end
    end

    local gutterMinions = self.geometry.gutterMinions
    for i = 1, #gutterMinions do
      if math.insideCircle(mx, my, unpack(gutterMinions[i])) then
        self.tooltip:setUnitTooltip(self.user.minions[i])
        break
      end
    end
  end
end

function Menu:draw()
  local u, v = love.graphics.getDimensions()
  g.setColor(255, 255, 255)
  if self.choosing then
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
  end

  self.tooltip:draw()
end

function Menu:keypressed(key)
  if self.choosing then return end
	if key == 'return' and table.has(self.user.biomes, config.biomeOrder[self.selectedBiome]) then
    self:startGame()
  elseif key == 'left' then
    self.selectedBiome = self.selectedBiome - 1
    if self.selectedBiome <= 0 then self.selectedBiome = #config.biomeOrder end
  elseif key == 'right' then
    self.selectedBiome = self.selectedBiome + 1
    if self.selectedBiome >= #config.biomeOrder + 1 then self.selectedBiome = 1 end
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
      local biomes = self.geometry.biomes
      for i = 1, #biomes do
        local x, y, w, h = unpack(biomes[i])
        if math.inside(mx, my, x, y, w, h) then
          self:startGame()
        end
      end

      local gutterMinions = self.geometry.gutterMinions
      for i = 1, #gutterMinions do
        if #ctx.user.deck.minions < 3 and math.insideCircle(mx, my, unpack(gutterMinions[i])) then
          table.insert(ctx.user.deck.minions, self.user.minions[i])
          table.remove(self.user.minions, i)
          self.user.deck.runes[#ctx.user.deck.minions] = {}
          table.clear(self.geometry)
          saveUser(self.user)
        end
      end
    elseif b == 'r' then
      local deck = self.geometry.deck
      for i = 1, #deck do
        local x, y, r, runes = unpack(deck[i])
        if self.user.deck.minions[i] and math.insideCircle(mx, my, x, y, r) then
          local code = self.user.deck.minions[i]
          table.insert(self.user.minions, code)
          while #self.user.deck.runes[i] > 0 do
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
            end
          end
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
