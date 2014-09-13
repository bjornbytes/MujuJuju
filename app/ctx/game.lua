Game = class()

function Game:load()
	self.paused = false
	self.ded = false
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
	self.effects:add(Wave)
	self.effects:add(DeathBlur)
	self.hud = Hud()
	self.upgrades = Upgrades
	self.upgrades:clear()
	self.target = Target()
	self.sound = Sound()
	self.sounds = {
		background = 'background',
		summon1 = 'summon1',
		summon2 = 'summon2',
		summon3 = 'summon3',
		spirit = 'spirit',
		juju1 = 'juju1',
		juju2 = 'juju2',
		juju3 = 'juju3',
		juju4 = 'juju4',
		juju5 = 'juju5',
		juju6 = 'juju6',
		juju7 = 'juju7',
		juju8 = 'juju8',
		combat = 'combat',
		death = 'death',
		menuClick = 'menuClick'
	}

	backgroundSound = self.sound:loop({sound = self.sounds.background})
	love.audio.setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.graphics.getHeight() / 2)
	love.keyboard.setKeyRepeat(false)
end

function Game:update()
	if self.hud.upgrading or self.paused or self.ded then
		self.player.prevx = self.player.x
		self.player.prevy = self.player.y
		if self.player.ghost then
			self.player.ghost.prevx = self.player.ghost.x
			self.player.ghost.prevy = self.player.ghost.y
		end
		self.hud:update()
		if self.ded then self.effects:get(DeathBlur):update() end
		return
	end
	self.enemies:update()
	self.minions:update()
	self.player:update()
	self.shrine:update()
	self.jujus:update()
	self.view:update()
	self.hud:update()
	self.effects:update()
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
	self.effects:resize()
end

function Game:keypressed(key)
	if not self.ded then
		if (key == 'p' or key == 'escape') and not self.hud.upgrading then self.paused = not self.paused
		elseif key == 'm' then self.sound:mute()
		elseif key == 'f' then love.window.setFullscreen(not love.window.getFullscreen()) end
	end
	if self.hud.upgrading or self.paused or self.ded then return self.hud:keypressed(key) end
	self.hud:keypressed(key)
	self.player:keypressed(key)
end

function Game:keyreleased(...)
	if self.hud.upgrading or self.paused or self.ded then return self.hud:keyreleased(...) end
end

function Game:textinput(char)
	self.hud:textinput(char)
end

function Game:mousepressed(...)
	if self.hud.upgrading or self.paused or self.ded then return self.hud:mousepressed(...) end
end

function Game:mousereleased(...)
	if self.hud.upgrading or self.paused or self.ded then return self.hud:mousereleased(...) end
end

function Game:gamepadpressed(gamepad, button)
	if button == 'start' or button == 'guide' then self.paused = not self.paused end
	if self.hud.upgrading or self.paused or self.ded then return self.hud:gamepadpressed(gamepad, button) end
	self.hud:gamepadpressed(gamepad, button)
	self.player:gamepadpressed(gamepad, button)
end
