Hud = class()

local g = love.graphics

function Hud:init()
	self.font = g.newFont('media/fonts/pixel.ttf', 8)
	ctx.view:register(self, 'gui')
end

function Hud:gui()
	g.setFont(self.font)
	g.setColor(255, 255, 255)

	g.print(ctx.player.jujuJuice .. ' jujuJuice', 2, 0)
end
