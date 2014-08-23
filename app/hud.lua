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
	
	local px, py = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate)
	g.print(ctx.player.health .. ' / ' .. ctx.player.maxHealth, px, py)
	g.print(ctx.shrine.health .. ' / ' .. ctx.shrine.maxHealth, ctx.shrine.x, ctx.shrine.y)

	table.each(ctx.enemies.enemies, function(enemy)
		g.print(enemy.health .. ' / ' .. enemy.maxHealth, enemy.x, enemy.y)
	end)

	table.each(ctx.minions.minions, function(minion)
		g.print(minion.health .. ' / ' .. minion.maxHealth, minion.x, minion.y)
	end)
end
