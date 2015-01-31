Game = class()

function Game:load(user, biome, options)
  self.options = options

  if self.options.textureSmoothing then
    data.media.graphics.juju:setMipmapFilter('linear', 1)
    data.media.graphics.map.forest:setMipmapFilter('linear', 1)
    data.media.graphics.map.forestSpirit:setMipmapFilter('linear', 1)
    for i = 1, 9 do
      data.media.graphics.runes[i]:setMipmapFilter('linear', 1)
    end
    data.media.graphics.hud.minion:setMipmapFilter('linear', 1)
    data.media.graphics.hud.population:setMipmapFilter('linear', 1)
  end

  self.user = user
  self.id = 1
  self.biome = biome

  self.paused = false
  self.ded = false
  self.timer = 0

  self.event = Event()
  self.view = View()
  self.map = Map()
  self.players = Players()
  self.player = ctx.players:add(1)
  self.shrujuPatches = ShrujuPatches()
  self.cursor = Cursor()
  self.hud = Hud()
  self.upgrades = Upgrades
  self.shrines = Manager()
  self.shrine = self.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
  self.units = Units()
  self.spells = Spells()
  self.jujus = Jujus()
  self.particles = Particles()
  self.target = Target()
  self.sound = Sound()
  self.effects = Effects()

  Upgrades.clear()

  self.event:on('shrine.dead', function(data)
    self.ded = true
    self:distribute()
  end)

  backgroundSound = self.sound:loop('background')
  love.keyboard.setKeyRepeat(false)

  if self.options.muted then self.sound:mute() end
end

function Game:update()
  self.cursor:update()

  if self.hud.upgrading or self.paused or self.ded then
    self.hud:update()
    if self.ded and self.effects:get('deathblur') then self.effects:get('deathblur'):update() end
    self.players:paused()
    self.units:paused()
    self.spells:paused()
    self.particles:update()
    return
  end

  self.timer = self.timer + 1

  self.players:update()
  self.units:update()
  self.shrines:update()
  self.jujus:update()
  self.spells:update()
  self.view:update()
  self.hud:update()
  self.effects:update()
  self.particles:update()
  self.shrujuPatches:update()
end

function Game:unload()
  backgroundSound:stop()
end

function Game:draw()
  self.view:draw()
end

function Game:resize()
  self.hud:resize()
  self.view:resize()
  self.effects:resize()
end

function Game:keypressed(key)
  if not self.ded then
    if key == 'p' or (key == 'escape' and not self.hud:menuActive()) then self.paused = not self.paused
    elseif key == 'm' then self.sound:mute() end
  end
  self.hud:keypressed(key)
  self.players:keypressed(key)
end

function Game:keyreleased(...)
  self.hud:keyreleased(...)
end

function Game:mousepressed(...)
  self.hud:mousepressed(...)
end

function Game:mousereleased(...)
  self.hud:mousereleased(...)
end

function Game:gamepadpressed(gamepad, button)
  if button == 'start' or button == 'guide' then self.paused = not self.paused end
  self.hud:gamepadpressed(gamepad, button)
  self.players:gamepadpressed(gamepad, button)
end

function Game:textinput(...)
  self.hud:textinput(...)
end

function Game:distribute()

  local function tableRandom(t)
    return t[love.math.random(1, #t)]
  end

  -- So the hud can draw them
  self.rewards = {runes = {}, biomes = {}, minions = {}}

  local time = math.floor(self.timer * tickRate)
  local bronze = time >= config.biomes[self.biome].benchmarks.bronze
  local silver = time >= config.biomes[self.biome].benchmarks.silver
  local gold = time >= config.biomes[self.biome].benchmarks.gold

  -- Distribute runes
  local runeCount = 0
  if bronze and love.math.random() < .9 then runeCount = runeCount + 1 end
  if silver and love.math.random() < .3 then runeCount = runeCount + 1 end
  if gold and love.math.random() < .2 then runeCount = runeCount + 1 end

  for i = 1, runeCount do

    -- Basics
    local rune = {}
    local maxLevel = config.biomes[ctx.biome].runes.maxLevel
    local mu = 0
    if gold then mu = maxLevel
    elseif silver then mu = maxLevel * .75
    elseif bronze then mu = maxLevel * .25 end

    local runeLevel = math.clamp(love.math.randomNormal(10, mu), 1, 100)

    -- Generate prefix
    local prefixes = config.runes.prefixes
    local prefixLevel = math.clamp(runeLevel + love.math.random(-4, 4), 0, 100)
    local prefix = prefixes[1 + math.round((prefixLevel / 100) * (#prefixes - 1))]
    rune.name = prefix .. ' Rune'

    -- Generate bonuses
    local r = love.math.random()
    if r < .33 then

      -- Attributes
      rune.attributes = {}
      local attribute = tableRandom(config.attributes.list)
      local attributeLevels = math.max(math.round((runeLevel / 100) * 8), 1)
      local attributeLevelsDistributed = 0
      local attributesDistributed = {attribute}
      while attributeLevelsDistributed < attributeLevels do
        local amount = love.math.random(1, attributeLevels - attributeLevelsDistributed)
        rune.attributes[attribute] = (rune.attributes[attribute] or 0) + amount
        attributeLevelsDistributed = attributeLevelsDistributed + amount
        if #attributesDistributed < 2 and love.math.random() < .4 then
          attribute = tableRandom(config.attributes.list)
          table.insert(attributesDistributed, attribute)
        end
      end

      table.sort(attributesDistributed)
      rune.name = rune.name .. ' of ' .. tableRandom(config.runes.suffixes.attributes[table.concat(attributesDistributed)])
    elseif r < .67 then

      -- Stat bonuses
      local stats = config.runes.stats
      local stat = stats[love.math.random(1, #stats)]
      local min, max = unpack(config.runes.statRanges[stat])
      local mu, sigma = math.lerp(min, max, runeLevel / 100), (max - min) / 10
      local amount = math.clamp(love.math.randomNormal(sigma, mu), min, max)
      rune.stats = {[stat] = amount}

      rune.name = rune.name .. ' of ' .. tableRandom(config.runes.suffixes.stats[stat])
    else

      -- Ability bonuses
      local unit = tableRandom(table.keys(config.runes.abilities))
      local ability = tableRandom(table.keys(config.runes.abilities[unit]))
      local stat = tableRandom(table.keys(config.runes.abilities[unit][ability]))
      local min, max = unpack(config.runes.abilities[unit][ability][stat])
      local mu, sigma = math.lerp(min, max, runeLevel / 100), (max - min) / 10
      local amount = math.clamp(love.math.randomNormal(sigma, mu), min, max)
      rune.unit = unit
      rune.abilities = {[ability] = {[stat] = amount}}

      rune.name = rune.name .. ' of ' .. tableRandom(config.runes.suffixes.abilities[ability])
    end

    -- Generate appearance
    rune.color = tableRandom(table.keys(config.runes.colors))
    rune.image = love.math.random(1, config.runes.imageCount)
    rune.background = runeLevel < 30 and 'broken' or 'normal'

    -- Add to account
    table.insert(self.user.runes, rune)
    table.insert(self.rewards.runes, rune)
  end

  -- Distribute biomes
  if silver then
    local nextBiome = config.biomes[self.biome].rewards.silver
    if nextBiome and not table.has(self.user.biomes, nextBiome) then
      table.insert(self.user.biomes, nextBiome)
      table.insert(self.rewards.biomes, nextBiome)
      saveUser(self.user)
    end
  end

  -- Calculate highscores
  if time > self.user.highscores[self.biome] then
    self.user.highscores[self.biome] = time
    self.rewards.highscore = true
    saveUser(self.user)
  end

  saveUser(self.user)
end
