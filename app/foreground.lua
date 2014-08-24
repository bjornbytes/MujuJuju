Foreground = class()

Foreground.depth = -50

function Foreground:init()
	self.grass = love.graphics.newImage('media/graphics/grass.png')
	self.spiritGrass = love.graphics.newImage('media/graphics/spiritGrass.png')
	self.spiritAlpha = 0
	ctx.view:register(self)
end

function Foreground:update()
	self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.player.dead and 1 or 0, .6 * tickRate)
end

function Foreground:draw()
	local g = love.graphics

	g.setColor(200, 200, 200)
	g.draw(self.grass, 0, 32)

	local alpha = self.spiritAlpha * 255
	alpha = math.lerp(alpha, (1 - (ctx.player.healthDisplay / ctx.player.maxHealth)) * 255, .5)
	g.setColor(200, 200, 200, alpha)
	g.draw(self.spiritGrass, 0, 32)
end
