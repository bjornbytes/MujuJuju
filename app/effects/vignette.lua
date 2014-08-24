Vignette = {}

function Vignette:init()
  self:resize()
	self.radius = 1
  self.shader:send('blur', .45)
end

function Vignette:update()
	self.radius = math.lerp(self.radius, ctx.player.dead and .875 or 1, 3 * tickRate)
	self.shader:send('radius', self.radius)
end

function Vignette:resize()
  self.shader = love.graphics.newShader('media/shaders/vignette.shader')
  self.shader:send('frame', {0, 0, love.graphics.getDimensions()})
end
