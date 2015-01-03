Game = class()

function Game:load()
  self.id = 1

	self.paused = false
	self.ded = false

  self.event = Event()
	self.view = View()
  self.map = Map()
  self.players = Players()
  ctx.players:add(1)

  self.shrujuTimer = love.math.random(30, 60)

  self.hud = Hud()
  self.upgrades = Upgrades()
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

  self.event:on('shrine.dead', function(data)
    self.ded = true
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
  self.shrujuTimer = timer.rot(self.shrujuTimer, function()
    if not self.sp1 then
      self.sp1 = ShrujuPatch()
      self.sp1:activate(1)
      self.hud.shrujuPatch1.patch = self.sp1
      return love.math.random(120, 180)
    else
      self.sp2 = ShrujuPatch()
      self.sp2:activate(2)
      self.hud.shrujuPatch2.patch = self.sp2
    end
  end)
  if self.sp1 then self.sp1:update() end
  if self.sp2 then self.sp2:update() end
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
	self.players:keypressed(key)
end

function Game:keyreleased(...)
	if self.hud.upgrading or self.paused or self.ded then return self.hud:keyreleased(...) end
end

function Game:textinput(char)
	self.hud:textinput(char)
end

function Game:mousepressed(...)
	if true or self.hud.upgrading or self.paused or self.ded then return self.hud:mousepressed(...) end
end

function Game:mousereleased(...)
	if self.hud.upgrading or self.paused or self.ded then return self.hud:mousereleased(...) end
end

function Game:gamepadpressed(gamepad, button)
	if button == 'start' or button == 'guide' then self.paused = not self.paused end
	if self.hud.upgrading or self.paused or self.ded then return self.hud:gamepadpressed(gamepad, button) end
	self.hud:gamepadpressed(gamepad, button)
	self.players:gamepadpressed(gamepad, button)
end
