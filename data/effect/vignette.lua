local g = love.graphics
local Vignette = {}

function Vignette:init()
  self:resize()
  self.config = config.effects[ctx.biome].vignette
	self.radius = self.config.radius[1]
	self.blur = self.config.blur[1]
end

function Vignette:update()
  local p = ctx.player
  self.config = config.effects[ctx.biome].vignette
	self.blur = lume.lerp(self.blur, p.dead and self.config.blur[2] or self.config.blur[1], 2 * ls.tickrate)
	self.radius = lume.lerp(self.radius, p.dead and self.config.radius[2] or self.config.radius[1], 4 * ls.tickrate)
	self.shader:send('blur', self.blur)
	self.shader:send('radius', self.radius)
end

function Vignette:applyEffect(source, target)
  g.setShader(self.shader)
  g.setCanvas(target)
  g.draw(source)
  g.setShader()
  ctx.view:worldPush()
  if ctx.player.ghost then ctx.player.ghost:draw() end
  ctx.jujus:draw()
  g.pop()
end

function Vignette:resize()
  self.shader = love.graphics.newShader('media/shaders/vignette.shader')
  self.shader:send('frame', {0, 0, love.graphics.getDimensions()})
end

return Vignette
