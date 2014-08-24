local Vignette = {}

function Vignette:init()
  self.radius = .85
  self:resize()
  self.shader:send('radius', self.radius)
  self.shader:send('blur', .45)
end

function Vignette:update()
	self.radius = math.lerp(self.radius, ctx.player.dead and .5 or 1, 1 * tickRate)
	self.shader:send('radius', self.radius)
end

function Vignette:resize()
  self.shader = love.graphics.newShader('media/shaders/vignette.shader')
  self.shader:send('frame', {0, 0, love.graphics.getDimensions()})
end

return Vignette
