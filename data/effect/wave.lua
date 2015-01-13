local Wave = class()

function Wave:init()
  self:resize()
	self.strength = {0, 0}
end

function Wave:update()
  local p = ctx.player
  local ratio = love.graphics.getWidth() / love.graphics.getHeight()
	self.strength[1] = math.lerp(self.strength[1], p.dead and .005 or 0, 4 * tickRate)
	self.strength[2] = math.lerp(self.strength[2], p.dead and (.005 * ratio) or 0, 4 * tickRate)
	self.shader:send('time', tick * .08)
	self.shader:send('strength', self.strength)
end

function Wave:resize()
  self.shader = data.media.shaders.wave
end

return Wave
