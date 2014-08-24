Hud = class()

local g = love.graphics

function Hud:init()
	self.font = g.newFont('media/fonts/pixel.ttf', 8)
	self.upgrading = false
	self.upgradeAlpha = 0
	ctx.view:register(self, 'gui')
end

function Hud:update()
	self.upgradeAlpha = math.lerp(self.upgradeAlpha, self.upgrading and 1 or 0, 12 * tickRate)
end

function Hud:gui()
	local w, h = love.graphics.getDimensions()

	g.setFont(self.font)
	g.setColor(255, 255, 255)

	g.print(math.floor(ctx.player.juju) .. ' juju', 2, 0)
	
	local px, py = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate)
	g.print(ctx.player.health .. ' / ' .. ctx.player.maxHealth, px, py - 30)
	g.print(ctx.shrine.health .. ' / ' .. ctx.shrine.maxHealth, ctx.shrine.x, ctx.shrine.y)

	table.each(ctx.enemies.enemies, function(enemy)
		g.print(enemy.health .. ' / ' .. enemy.maxHealth, enemy.x, enemy.y)
	end)

	table.each(ctx.minions.minions, function(minion)
		g.print(minion.health .. ' / ' .. minion.maxHealth, minion.x, minion.y)
	end)

	if self.upgradeAlpha > .001 then
		local w2, h2 = w / 2, h / 2
		local x1, y1 = w2 - 300, h2 - 200
		local w, h = 600, 400
		g.setColor(0, 0, 0, self.upgradeAlpha * 220)
		g.rectangle('fill', x1, y1, w, h)

		g.setColor(255, 255, 255, self.upgradeAlpha * 255)
		g.rectangle('line', x1, y1, w, h)

		local xx
		local idx

		-- Juju box
		g.rectangle('line', w2 - 32, h2 - 184, 64, 64)
		g.print(math.floor(ctx.player.juju), w2 - 32 + 3, h2 - 184)

		-- Fetish
		g.rectangle('line', x1 + (w * .25) - 32, h2 - 144, 64, 64)
		xx = x1 + (w * .25)
		idx = 1
		for i = xx - 64, xx + 64, 64 do
			g.rectangle('line', i - 24, h2 - 144 + 80, 48, 48)
			local key = ctx.upgrades.keys.zuju[idx]
			local name = ctx.upgrades.names.zuju[key]
			local cost = ctx.upgrades.costs.zuju[key][ctx.upgrades.zuju[key] + 1] or ''
			g.print(name .. '\n' .. cost, i - 24 + 3, h2 - 144 + 80)
			idx = idx + 1
		end

		-- Voodoo
		g.rectangle('line', x1 + (w * .75) - 32, h2 - 144, 64, 64)
		if #ctx.player.minions < 2 then
			g.print('vuju\n250', x1 + (w * .75) - 32 + 3, h2 - 144)
		end
		xx = x1 + (w * .75)
		idx = 1
		for i = xx - 64, xx + 64, 64 do
			g.rectangle('line', i - 24, h2 - 144 + 80, 48, 48)
			local key = ctx.upgrades.keys.vuju[idx]
			local name = ctx.upgrades.names.vuju[key]
			local cost = ctx.upgrades.costs.vuju[key][ctx.upgrades.vuju[key] + 1] or ''
			g.print(name .. '\n' .. cost, i - 24 + 3, h2 - 144 + 80)
			idx = idx + 1
		end

		-- MUUUUUUUUUUUUJU
		g.rectangle('line', x1 + (w * .5) - 32, h2 + 16, 64, 64)
		xx = x1 + (w * .5)
		idx = 1
		for i = xx - 64, xx + 64, 64 do
			g.rectangle('line', i - 24, h2 + 16 + 80, 48, 48)
			local key = ctx.upgrades.keys.muju[idx]
			local name = ctx.upgrades.names.muju[key]
			local cost = ctx.upgrades.costs.muju[key][ctx.upgrades.muju[key] + 1] or ''
			g.print(name .. '\n' .. cost, i - 24 + 3, h2 + 16 + 80)
			idx = idx + 1
		end
	end
end

function Hud:keypressed(key)
	if (key == 'tab' or key == 'e') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
		self.upgrading = not self.upgrading
		return true
	end
end

function Hud:keyreleased(key)

end

function Hud:mousepressed(x, y, b)

end

function Hud:mousereleased(x, y, b)
	if self.upgrading then
		local w, h = love.graphics.getDimensions()
		local w2, h2 = w / 2, h / 2
		local x1, y1 = w2 - 300, h2 - 200
		local w, h = 600, 400
		local xx

		xx = x1 + (w * .25)
		local idx = 1
		for i = xx - 64, xx + 64, 64 do
			if math.inside(x, y, i - 24, h2 - 144 + 80, 48, 48) then
				local key = ctx.upgrades.keys.zuju[idx]
				local cost = ctx.upgrades.costs.zuju[key][ctx.upgrades.zuju[key] + 1]
				if cost and ctx.player:spend(cost) then
					ctx.upgrades.zuju[key] = ctx.upgrades.zuju[key] + 1
				end
			end
			idx = idx + 1
		end

		xx = x1 + (w * .75)
		local idx = 1
		for i = xx - 64, xx + 64, 64 do
			if math.inside(x, y, i - 24, h2 - 144 + 80, 48, 48) then
				local key = ctx.upgrades.keys.vuju[idx]
				local cost = ctx.upgrades.costs.vuju[key][ctx.upgrades.vuju[key] + 1]
				if cost and ctx.player:spend(cost) then
					ctx.upgrades.vuju[key] = ctx.upgrades.vuju[key] + 1
				end
			end
			idx = idx + 1
		end

		xx = x1 + (w * .5)
		local idx = 1
		for i = xx - 64, xx + 64, 64 do
			if math.inside(x, y, i - 24, h2 + 16 + 80, 48, 48) then
				local key = ctx.upgrades.keys.muju[idx]
				local cost = ctx.upgrades.costs.muju[key][ctx.upgrades.muju[key] + 1]
				if cost and ctx.player:spend(cost) then
					ctx.upgrades.muju[key] = ctx.upgrades.muju[key] + 1
				end
			end
			idx = idx + 1
		end

		g.rectangle('line', x1 + (w * .75) - 32, h2 - 144, 64, 64)
		if #ctx.player.minions < 2 and math.inside(x, y, x1 + (w * .75) - 32, h2 - 144, 64, 64) then
			if ctx.player:spend(350) then
				table.insert(ctx.player.minions, Voodoo)
				table.insert(ctx.player.minioncds, 0)
			end
		end
	end
end

