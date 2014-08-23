Environment = class()

function Environment:init()
	self.groundHeight = 128
	ctx.view:register(self)
end

function Environment:draw()
	local g, w, h = love.graphics, love.graphics.getDimensions()

	g.setColor(60, 40, 0)
	g.rectangle('fill', 0, h - self.groundHeight, w, self.groundHeight)
end
