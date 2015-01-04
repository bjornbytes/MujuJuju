Game = class()

function Game:load(user, biome)
  self.id = 1
  self.user = user
  self.biome = biome and 'volcano'

	self.paused = false
	self.ded = false

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

    local time = math.round(self.hud.timer.total * tickRate)
    if time > self.user.highscores[self.biome] then
      self.user.highscores[self.biome] = time
      saveUser(self.user)
    end

    if time >= config.biomes[self.biome].benchmarks.bronze then
      -- give some runes randomly proabbilsithi
    end

    if time >= config.biomes[self.biome].benchmarks.silver then
      local nextBiome = config.biomes[self.biome].rewards.silver
      if nextBiome then
        table.insert(self.user.biomes, nextBiome)
        saveUser(self.user)
      else
        -- give a fancy rune
      end
    end

    if time >= config.biomes[self.biome].benchmarks.gold then
      local nextMinion = config.biomes[self.biome].rewards.gold
      if nextMinion and not table.has(self.user.deck, nextMinion) then
        table.insert(self.user.deck, nextMinion)
        saveUser(self.user)
      end
    end
  end)

	backgroundSound = self.sound:loop({sound = 'background'})
	love.keyboard.setKeyRepeat(false)
end

function Game:update()
	if self.hud.upgrading or self.paused or self.ded then
		self.hud:update()
		if self.ded then self.effects:get('deathBlur'):update() end
		return
	end
	self.players:update()
	self.units:update()
	self.shrines:update()
	self.jujus:update()
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
	self.view:resize()
	self.effects:resize()
end

function Game:keypressed(key)
	if not self.ded then
		if (key == 'p' or key == 'escape') and not self.hud.upgrading then self.paused = not self.paused
		elseif key == 'm' then self.sound:mute()
		elseif key == 'f' then love.window.setFullscreen(not love.window.getFullscreen()) end
	end
	self.hud:keypressed(key)
	self.players:keypressed(key)
end

function Game:keyreleased(...)
  self.hud:keyreleased(...)
end

function Game:textinput(char)
	self.hud:textinput(char)
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
