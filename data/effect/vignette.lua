local Vignette = {}
Vignette.code = 'vignette'

function Vignette:init()
  self:resize()
  self.config = config.biomes[ctx.biome].effects.vignette
	self.radius = self.config.radius[1]
	self.blur = self.config.blur[1]
end

function Vignette:update()
  local p = ctx.player
	self.blur = math.lerp(self.blur, p.dead and self.config.blur[2] or self.config.blur[1], 2 * tickRate)
	self.radius = math.lerp(self.radius, p.dead and self.config.radius[2] or self.config.radius[1], 4 * tickRate)
	self.shader:send('blur', self.blur)
	self.shader:send('radius', self.radius)
end

function Vignette:resize()
  self.shader = love.graphics.newShader('media/shaders/vignette.shader')
  self.shader:send('frame', {0, 0, love.graphics.getDimensions()})
end

return Vignette
