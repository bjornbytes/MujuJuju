Vignette = {}

function Vignette:init()
  self:resize()
	self.radius = .85
	self.blur = .45
end

function Vignette:update()
	self.blur = math.lerp(self.blur, ctx.player.dead and 1.15 or .45, 2 * tickRate)
	--self.radius = math.lerp(self.radius, ctx.player.dead and .85 - (.35 * ctx.player.jujuRealm / 7) or .85, 4 * tickRate)
	self.shader:send('blur', self.blur)
	self.shader:send('radius', self.radius)
end

function Vignette:resize()
  self.shader = love.graphics.newShader('media/shaders/vignette.shader')
  self.shader:send('frame', {0, 0, love.graphics.getDimensions()})
end
