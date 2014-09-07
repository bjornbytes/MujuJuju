Wave = {}
Wave = class()

function Wave:init()
  self:resize()
	self.strength = {0, 0}
end

function Wave:update()
	self.strength[1] = math.lerp(self.strength[1], ctx.player.dead and .005 or 0, .5 * tickRate)
	self.strength[2] = math.lerp(self.strength[2], ctx.player.dead and .005 * 4 / 3 or 0, .5 * tickRate)
	self.shader:send('time', tick)
	self.shader:send('strength', self.strength)
end

function Wave:resize()
  self.shader = love.graphics.newShader('media/shaders/wave.shader')
end
