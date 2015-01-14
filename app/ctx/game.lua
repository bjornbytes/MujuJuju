Game = class()

function Game:load(user, biome)
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
  self.won = false
  self.timer = 0

  self.event = Event()
	self.view = View()
  self.map = Map()
  self.players = Players()
  self.player = ctx.players:add(1)
  self.shrujuPatches = ShrujuPatches()
  self.hud = Hud()
  self.upgrades = Upgrades
  self.shrines = Manager()
  self.shrine = self.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
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
		if self.ded and self.effects:get('deathblur') then self.effects:get('deathblur'):update() end
    self.players:paused()
    self.units:paused()
    self.spells:paused()
    self.particles:update()
		return
	end

  if not self.won then self.timer = self.timer + 1 end

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

  -- Distribute runes
  local runeCount = 0
  if self.biome == 'forest' and love.math.random() < .5 then runeCount = 1
  elseif self.biome == 'cavern' then runeCount = 1 + math.round(love.math.random())
  elseif self.biome == 'tundra' then runeCount = 1 + math.round(2 * love.math.random())
  elseif self.biome == 'volcano' then runeCount = 1 + math.round(2 * love.math.random()) end

  for i = 1, runeCount do
    local rune = {}
    local maxLevel = config.biomes[ctx.biome].runes.maxLevel
    local runeLevel = love.math.random(1, maxLevel)

    rune.attributes = {}
    local attributes = config.attributes
    local attribute = attributes[love.math.random(1, #attributes)]
    local attributeLevels = math.max(math.round((runeLevel / 100) * 8), 1)
    local attributesDistributed = 0
    while attributesDistributed < attributeLevels do
      local amount = love.math.random(1, attributeLevels - attributesDistributed)
      rune.attributes[attribute] = (rune.attributes[attribute] or 0) + amount
      attributesDistributed = attributesDistributed + amount
      if love.math.random() < .2 then
        attribute = attributes[love.math.random(1, #attributes)]
      end
    end

    rune.name = 'Rune'

    local prefixes = config.runes.prefixes
    local prefixLevel = math.clamp(runeLevel + love.math.random(-3, 3), 0, 100)
    local prefix = prefixes[1 + math.round((prefixLevel / 100) * (#prefixes - 1))]

    rune.name = prefix .. ' ' .. rune.name

    local colors = table.keys(config.runes.colors)
    rune.color = colors[love.math.random(1, #colors)]
    rune.image = love.math.random(1, config.runes.imageCount)
    rune.background = runeLevel < 30 and 'broken' or 'normal'

    table.insert(self.user.runes, rune)
    table.insert(self.rewards.runes, rune)
  end

  saveUser(self.user)

  -- Distribute minions
  --[[if self.user.highscores[self.biome] < config.biomes[self.biome].benchmarks.gold then
    local minions = table.copy(self.user.minions)
    for i = 1, #self.user.deck.minions do table.insert(minions, self.user.deck.minions[i]) end
    if #config.starters > #minions then
      local idx = love.math.random(1, #config.starters)
      for i = 1, 100 do
        local minion = config.starters[idx]
        if not table.has(minions, minion) then
          table.insert(self.user.deck.minions, minion)
          table.insert(self.rewards.minions, minion)
          saveUser(self.user)
          break
        end
        idx = love.math.random(1, #config.starters)
      end
    end
  end]]

  --[[if time > self.user.highscores[self.biome] then
    self.user.highscores[self.biome] = time
    self.rewards.highscore = true
    saveUser(self.user)
  end]]
end

function Game:nextBiome()
  local biomeIndex
  for i = 1, #config.biomeOrder do if config.biomeOrder[i] == self.biome then biomeIndex = i break end end
  if not config.biomeOrder[biomeIndex + 1] then
    Context:remove(ctx)
    Context:add(Menu, biomeIndex)
  end
  self.biome = config.biomeOrder[biomeIndex + 1]

  self.units:clear()
  self.spells:clear()
  self.jujus:clear()
	self.effects:clear()
  self.won = false
end
