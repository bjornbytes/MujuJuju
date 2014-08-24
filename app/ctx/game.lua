Game = class()

function Game:load()
	self.paused = false
	self.view = View()
	self.environment = Environment()
	self.foreground = Foreground()
	self.enemies = Enemies()
	self.minions = Minions()
	self.player = Player()
	self.shrine = Shrine()
	self.jujus = Jujus()
	self.particles = Particles()
	self.effects = Effects()
	self.effects:add(Vignette)
	self.effects:add(Bloom)
	self.hud = Hud()
	self.upgrades = Upgrades
	self.upgrades:clear()
	self.target = Target()
	self.sound = Sound()
	self.sounds = {
		background = 'background',
		summon = 'summon',
		spirit = 'spirit',
		juju = 'juju',
		combat = 'combat',
		death = 'death',
		menuClick = 'menuClick'
	}

	backgroundSound = self.sound:play({sound = self.sounds.background})
end

function Game:update()
	if self.hud.upgrading or self.paused then
		self.player.prevx = self.player.x
		self.player.prevy = self.player.y
		self.hud:update()
		return
	end
	self.enemies:update()
	self.minions:update()
	self.player:update()
	self.shrine:update()
	self.jujus:update()
	self.effects:update()
	self.view:update()
	self.hud:update()
	self.particles:update()
	self.environment:update()
	self.foreground:update()
end

function Game:unload()
	backgroundSound:stop()
end

function Game:draw()
	self.view:draw()
end

function Game:resize()
	self.view:resize()
end

function Game:keypressed(key)
	if key == 'p' then self.paused = not self.paused end
	if self.hud.upgrading or self.paused then return self.hud:keypressed(key) end
	self.hud:keypressed(key)
	self.player:keypressed(key)

	if key == 'escape' then
		love.event.quit()
	end
end

function Game:keyreleased(...)
	if self.hud.upgrading or self.paused then return self.hud:keyreleased(...) end
	self.player:keyreleased(...)
end

function Game:mousepressed(...)
	if self.hud.upgrading or self.paused then return self.hud:mousepressed(...) end
	self.player:mousepressed(...)
end

function Game:mousereleased(...)
	if self.hud.upgrading or self.paused then return self.hud:mousereleased(...) end
	self.player:mousereleased(...)
end
