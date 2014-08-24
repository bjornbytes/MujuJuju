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

	g.setColor(200, 200, 200, self.spiritAlpha * 200)
	g.draw(self.spiritGrass, 0, 32)
end
