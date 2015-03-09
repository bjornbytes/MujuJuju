Game = class()

function Game:load(user, options, info)
  self.options = options

  if self.options.textureSmoothing then
    data.media.graphics.juju:setMipmapFilter('linear', 1)
    data.media.graphics.map.forest:setMipmapFilter('linear', 1)
    data.media.graphics.map.forestSpirit:setMipmapFilter('linear', 1)
    data.media.graphics.atlas.hud:setMipmapFilter('linear', 1)
    data.media.graphics.hud.population:setMipmapFilter('linear', 1)
    data.media.graphics.hud.clockBlue:setMipmapFilter('linear', 1)
    data.media.graphics.hud.clockBronze:setMipmapFilter('linear', 1)
    data.media.graphics.hud.clockSilver:setMipmapFilter('linear', 1)
    data.media.graphics.hud.clockGold:setMipmapFilter('linear', 1)
  end

  self.user = user
  self.id = 1
  self.mode = info.mode
  self.biome = info.biome

  self.paused = false
  self.ded = false
  self.timer = 0

  self.event = Event()
  self.view = View()
  self.map = Map()
  self.players = Players()
  self.player = ctx.players:add(1)
  self.shrujus = Shrujus()
  self.hud = Hud()
  self.upgrades = Upgrades
  self.shrines = Manager()
  self.shrine = self.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
  self.units = Units()
  self.spells = Spells()
  self.particles = Particles()
  self.target = Target()
  self.sound = Sound(self.options)
  self.effects = Effects()
  self.jujus = Jujus()
  self.achievements = Achievements(self.user)

  self.tutorial = Tutorial(info.tutorial)

  Upgrades.clear()

  self.event:on('shrine.dead', function(data)
    self.youlose = ctx.sound:play('youlose')
    self.ded = true
    self:distribute()
  end)

  self.backgroundSound = self.sound:loop(self.biome)
  love.keyboard.setKeyRepeat(false)

  if self.options.mute then self.sound:mute() end
end

function Game:update()
  if self.hud.upgrades.active or self.paused or self.ded then
    self.hud:update()
    if self.ded and self.effects:get('deathblur') then self.effects:get('deathblur'):update() end
    self.players:paused()
    self.units:paused()
    self.spells:paused()
    self.particles:update()
    self.tutorial:update()
    return
  end

  self.timer = self.timer + 1
  ls.framerate = self.options.powersave and (love.system.getPowerInfo() == 'battery' and 30 or 60) or -1
  ls.timescale = love.keyboard.isDown('lshift') and 3 or 1

  self.players:update()
  self.units:update()
  self.shrines:update()
  self.jujus:update()
  self.spells:update()
  self.map:update()
  self.view:update()
  self.hud:update()
  self.effects:update()
  self.shrujus:update()
  self.tutorial:update()
end

function Game:unload()
  self.backgroundSound:stop()
  if self.youlose then self.youlose:stop() end
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
  self.tutorial:keypressed(key)
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

function Game:mousemoved(...)
  self.hud:mousemoved(...)
end

function Game:gamepadpressed(gamepad, button)
  print('Game:gamepadpressed', gamepad, button)
  if button == 'start' or button == 'guide' then self.paused = not self.paused end
  self.hud:gamepadpressed(gamepad, button)
  self.players:gamepadpressed(gamepad, button)
end

function Game:gamepadaxis(...)
  self.players:gamepadaxis(...)
end

function Game:distribute()

  local function tableRandom(t)
    return t[love.math.random(1, #t)]
  end

  -- So the hud can draw them
  self.rewards = {runes = {}, medals = {}}

  local time = math.floor(self.timer * ls.tickrate)
  local bronze = time >= config.medals.bronze
  local silver = time >= config.medals.silver
  local gold = time >= config.medals.gold

  -- Distribute medals
  if bronze and not ctx.user.campaign.medals[self.biome].bronze then
    table.insert(self.rewards.medals, 'bronze')
    self.user.campaign.medals[self.biome].bronze = true
  end

  if silver and not ctx.user.campaign.medals[self.biome].silver then
    table.insert(self.rewards.medals, 'silver')
    self.user.campaign.medals[self.biome].silver = true
  end

  if gold and not ctx.user.campaign.medals[self.biome].gold then
    table.insert(self.rewards.medals, 'gold')
    self.user.campaign.medals[self.biome].gold = true
  end

  -- Distribute runes
  local runeCount = 0
  if bronze then runeCount = runeCount + 1 end
  if silver and love.math.random() < .3 then runeCount = runeCount + 1 end
  if gold and love.math.random() < .2 then runeCount = runeCount + 1 end

  for i = 1, runeCount do

    -- Basics
    local rune = {}
    local maxLevel = config.runes.maxLevels[self.biome]
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
          if not table.has(attributesDistributed, attribute) then
            table.insert(attributesDistributed, attribute)
          end
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
      if self.mode == 'campaign' and love.math.random() < .5 then unit = config.biomes[ctx.biome].minion end
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
    if #ctx.user.runes.stash < 32 then
      table.insert(self.user.runes.stash, rune)
      table.insert(self.rewards.runes, rune)
    end
  end

  -- Calculate highscores
  if self.mode == 'survival' and time > self.user.survival.bestTime then
    self.user.survival.bestTime = time
    self.rewards.highscore = true
  end

  saveUser(self.user)
end
