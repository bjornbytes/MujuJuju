Game = class()

function Game:load(user, biome)
  data.load()
  data.media.graphics.juju:setMipmapFilter('linear', 1)
  data.media.graphics.map.forest:setMipmapFilter('linear', 1)
  data.media.graphics.map.forestSpirit:setMipmapFilter('linear', 1)
  for i = 1, 9 do
    data.media.graphics.runes[i]:setMipmapFilter('linear', 1)
  end
  data.media.graphics.hud.minion:setMipmapFilter('linear', 1)
  data.media.graphics.hud.population:setMipmapFilter('linear', 1)

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
  ctx.players:add(1)
  self.shrujuPatches = ShrujuPatches()
  self.hud = Hud()
  self.upgrades = Upgrades
  self.shrines = Manager()
  self.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
  self.units = Units()
  self.spells = Spells()
  self.jujus = Jujus()
  self.particles = Particles()
  self.effects = Effects()
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
end

function Game:update()
	if self.hud.upgrading or self.paused or self.ded then
		self.hud:update()
		if self.ded then self.effects:get('deathBlur'):update() end
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
		elseif key == 'm' then self.sound:mute()
		elseif key == 'f' then love.window.setFullscreen(not love.window.getFullscreen()) end
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

function Game:distribute()

  -- So the hud can draw them
  self.rewards = {runes = {}, biomes = {}, minions = {}}

  local time = math.floor(self.timer * tickRate)

  local bronze = time >= config.biomes[self.biome].benchmarks.bronze
  local silver = time >= config.biomes[self.biome].benchmarks.silver
  local gold = time >= config.biomes[self.biome].benchmarks.gold

  -- Distribute runes
  local runeCount = 0
  if not bronze and love.math.random() < .3 then runeCount = runeCount + 1 end
  if bronze and love.math.random() < .9 then runeCount = runeCount + 1 end
  if silver and love.math.random() < .50 then runeCount = runeCount + 1 end
  if gold and love.math.random() < .25 then runeCount = runeCount + 1 end
  for i = 1, runeCount do
    local rune = {}
    local runeLevel = 0
    local maxLevel = config.biomes[ctx.biome].runes.maxLevel

    if gold then runeLevel = love.math.random(.67 * maxLevel, maxLevel)
    elseif silver then runeLevel = love.math.random(.33 * maxLevel, .67 * maxLevel)
    elseif bronze then runeLevel = love.math.random(0, .33 * maxLevel) end

    local upgrade = love.math.random() < config.biomes[ctx.biome].runes.specialChance * (runeLevel / 100)
    if upgrade then
      local upgrades = {}
      local function halp(unit, upgrade)
        local obj = unit.upgrades[upgrade]
        table.insert(upgrades, upgrade)
        upgrades[upgrade] = obj.name
      end

      -- Tier 2 check
      if love.math.random() < .5 * (runeLevel / 100) then
        table.each(config.starters, function(code)
          halp(data.unit[code], data.unit[code].upgradeOrder[4])
          halp(data.unit[code], data.unit[code].upgradeOrder[5])
        end)
      else
        table.each(config.starters, function(code)
          halp(data.unit[code], data.unit[code].upgradeOrder[1])
          halp(data.unit[code], data.unit[code].upgradeOrder[2])
          halp(data.unit[code], data.unit[code].upgradeOrder[3])
        end)
      end

      rune.upgrade = upgrades[love.math.random(1, #upgrades)]
      rune.name = 'Rune of ' .. upgrades[rune.upgrade]:capitalize()
    else
      local stats = config.runes.stats
      local stat = stats[love.math.random(1, #stats)]
      rune.stat = stat
      if love.math.random() < .5 then
        rune.amount = math.lerp(config.runes[stat].flatRange[1], config.runes[stat].flatRange[2], runeLevel / 100)
      else
        rune.scaling = math.lerp(config.runes[stat].scalingRange[1], config.runes[stat].scalingRange[2], runeLevel / 100)
      end

      local names = config.runes[rune.stat].names
      rune.name = names[love.math.random(1, #names)]

      local prefixes = config.runes.prefixes
      local prefixLevel = math.clamp(runeLevel + love.math.random(-3, 3), 0, 100)
      local prefix = prefixes[1 + math.round((prefixLevel / 100) * (#prefixes - 1))]

      rune.name = prefix .. ' ' .. rune.name
    end

    local colors = table.keys(config.runes.colors)
    rune.color = config.runes.colors[colors[love.math.random(1, #colors)]]
    rune.image = love.math.random(1, config.runes.imageCount)
    rune.background = runeLevel < 30 and 'broken' or 'normal'

    table.insert(self.user.runes, rune)
    table.insert(self.rewards.runes, rune)
  end

  saveUser(self.user)

  -- Distribute biomes
  if silver then
    local nextBiome = config.biomes[self.biome].rewards.silver
    if nextBiome and not table.has(self.user.biomes, nextBiome) then
      table.insert(self.user.biomes, nextBiome)
      table.insert(self.rewards.biomes, nextBiome)
      saveUser(self.user)
    end
  end

  -- Distribute minions
  if gold and self.user.highscores[self.biome] < config.biomes[self.biome].benchmarks.gold then
    local minions = table.copy(self.user.minions)
    for i = 1, #self.user.deck.minions do table.insert(minions, self.user.deck.minions[i]) end
    if #config.starters > #minions then
      local idx = love.math.random(1, #config.starters)
      for i = 1, 100 do
        local minion = config.starters[idx]
        if not table.has(minions, minion) then
          table.insert(self.user.minions, minion)
          table.insert(self.rewards.minions, minion)
          saveUser(self.user)
          break
        end
        idx = love.math.random(1, #config.starters)
      end
    end
  end

  if time > self.user.highscores[self.biome] then
    self.user.highscores[self.biome] = time
    self.rewards.highscore = true
    saveUser(self.user)
  end
end
