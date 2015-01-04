local Vignette = {}
Vignette.code = 'vignette'

function Vignette:init()
  self:resize()
	self.radius = .85
	self.blur = .45
end

function Vignette:update()
  local p = ctx.players:get(ctx.id)
	self.blur = math.lerp(self.blur, p.dead and .8 or .45, 2 * tickRate)
	--self.radius = math.lerp(self.radius, p.dead and .85 - (.35 * p.deathTimer / 7) or .85, 4 * tickRate)
	self.shader:send('blur', self.blur)
	self.shader:send('radius', self.radius)
end

function Vignette:resize()
  self.shader = love.graphics.newShader('media/shaders/vignette.shader')
  self.shader:send('frame', {0, 0, love.graphics.getDimensions()})
end

return Vignette
