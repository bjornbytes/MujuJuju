Hud = class()

local g = love.graphics
local rich = require 'lib/deps/richtext/richtext'

local pixelFont = love.graphics.newFont('media/fonts/pixel.ttf', 8)
local fancyFont = love.graphics.newFont('media/fonts/letterSseungi.ttf', 24)
Hud.richOptions = {title = fancyFont, pixel = pixelFont, white = {255, 255, 255}, whoCares = {220, 220, 220}, red = {255, 0, 0}, green = {0, 255, 0}}
Hud.upgradePositions = {
	zuju = {
		empower = {200 + 50, 50 * 1, 24},
		fortify = {200 + 50, 50 * 2, 24},
		burst = {200 + 50, 50 * 3, 24},
		siphon = {200 + 50, 50 * 4, 24},
		sanctuary = {200 + 50, 50 * 5, 24}
	},
	vuju = {
		surge = {200 + 50 * 2, 50 * 1, 24},
		charge = {200 + 50 * 2, 50 * 2, 24},
		condemn = {200 + 50 * 2, 50 * 3, 24},
		arc = {200 + 50 * 2, 50 * 4, 24},
		soak = {200 + 50 * 2, 50 * 5, 24}
	},
	muju = {
		flow = {200 + 50 * 3, 50 * 1, 24},
		harvest = {200 + 50 * 3, 50 * 2, 24},
		refresh = {200 + 50 * 3, 50 * 3, 24},
		zeal = {200 + 50 * 3, 50 * 4, 24},
		absorb = {200 + 50 * 3, 50 * 5, 24},
		diffuse = {200 + 50 * 3, 50 * 6, 24},
		imbue = {200 + 50 * 3, 50 * 7, 24},
		mirror = {200 + 50 * 3, 50 * 8, 24},
		distort = {200 + 50 * 3, 50 * 9, 24}
	}
}

function Hud:init()
	self.upgrading = false
	self.upgradeBg = g.newImage('media/graphics/upgrade-menu.png')
	self.lock = g.newImage('media/graphics/lock.png')
	self.upgradeAlpha = 0
	self.tooltip = nil
	self.tooltipRaw = ''
	self.jujuIcon = g.newImage('media/graphics/juju-icon.png')
	self.timer = {total = 0, minutes = 0, seconds = 0}
	ctx.view:register(self, 'gui')
end

function Hud:update()
	self.upgradeAlpha = math.lerp(self.upgradeAlpha, self.upgrading and 1 or 0, 12 * tickRate)

	-- Update Timer
	self:score()

	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local hover = false

		for who in pairs(self.upgradePositions) do
			for what, geometry in pairs(self.upgradePositions[who]) do
				if math.distance(mx, my, geometry[1], geometry[2]) < geometry[3] then
					local str = ctx.upgrades.makeTooltip(who, what)
					self.tooltip = rich.new(table.merge({str, 250}, self.richOptions))
					self.tooltipRaw = str:gsub('{%a+}', '')
					hover = true
					break
				end
			end
		end

		if not hover then self.tooltip = nil end
	end
end

function Hud:health(x, y, percent, color, width, thickness)
	local g = love.graphics
	thickness = thickness or 2

	g.setColor(0, 0, 0, 160)
	g.rectangle('fill', x, y, width + 1, thickness + 1)
	g.setColor(color)
	g.rectangle('fill', x, y, percent * width, thickness)
end

function Hud:stackingTable(stackingTable, x, range, delta)
	local limit = x + range
	for i = x - range, limit, 1 do
		if not stackingTable[i] then
			stackingTable[i] = 1 
		else 
			stackingTable[i] = stackingTable[i] + delta
		end
	end
end

function Hud:score()
	if not self.upgrading and not ctx.paused then
		self.timer.total = self.timer.total + 1
	end
end

function Hud:gui()
	local w, h = love.graphics.getDimensions()

	-- Timer
	local total = self.timer.total * tickRate
	self.timer.seconds = math.floor(total % 60)
	self.timer.minutes = math.floor(total / 60)

	if self.timer.minutes < 10 then
		self.timer.minutes = '0' .. self.timer.minutes
	end

	if self.timer.seconds < 10 then
		self.timer.seconds = '0' .. self.timer.seconds
	end

	g.setColor(255, 255, 255)
	g.print(self.timer.minutes .. ':' .. self.timer.seconds, w - 50, 25)
	if true then
		g.print('level ' .. math.floor(ctx.enemies.level), w - 150, 25 + g.getFont():getHeight())
		g.print('puju ' .. math.floor(Puju.maxHealth + 4 * ctx.enemies.level ^ 1.185) .. ' / ' .. math.floor(Puju.damage + .3 * ctx.enemies.level ^ 1.2), w - 150, 25 + 2 * g.getFont():getHeight())
		g.print('spuju ' .. math.floor(Spuju.maxHealth + 4 * ctx.enemies.level ^ 1) .. ' / ' .. math.floor(Spuju.damage + .45 * ctx.enemies.level ^ 1.4), w - 150, 25 + 3 * g.getFont():getHeight())
	end

	g.setFont(pixelFont)
	g.setColor(ctx.player.selectedMinion == 1 and {255, 255, 255} or {150, 150, 150})
	local upgradeCount = ctx.upgrades.zuju.empower.level + ctx.upgrades.zuju.fortify.level + ctx.upgrades.zuju.burst.level + ctx.upgrades.zuju.siphon.level + ctx.upgrades.zuju.sanctuary.level
	local cost = Zuju.cost + (3 * upgradeCount)
	g.print('Zuju [' .. math.round(cost) .. '] ' .. (ctx.player.minioncds[1] > 0 and math.ceil(ctx.player.minioncds[1]) or ''), 16, 100)
	if #ctx.player.minions == 2 then
		g.setColor(ctx.player.selectedMinion == 2 and {255, 255, 255} or {150, 150, 150})
		local cost = Vuju.cost
		local upgradeCount = 0
		g.print('Vuju [' .. cost + (3 * upgradeCount) .. '] ' .. (ctx.player.minioncds[2] > 0 and math.ceil(ctx.player.minioncds[2]) or ''), 16, 100 + g.getFont():getHeight() + 2)
	end
	
	-- Health Bars

	local px, py = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate)
	local green = {50, 230, 50}
	local red = {255, 0, 0}
	local purple = {200, 80, 255}

	self:health(px - 40, py - 15, ctx.player.healthDisplay / ctx.player.maxHealth, purple, 80, 3)
	self:health(ctx.shrine.x - 60, ctx.shrine.y - 65, ctx.shrine.healthDisplay / ctx.shrine.maxHealth, green, 120, 4)

	local stackingTable = {}
	table.each(ctx.enemies.enemies, function(enemy)
		local location = math.floor(enemy.x)
		self:stackingTable(stackingTable, location, enemy.width * 2, .5)
		self:health(enemy.x - 25, h - ctx.environment.groundHeight - enemy.height - 15 - 15 * stackingTable[location], enemy.healthDisplay / enemy.maxHealth, red, 50, 2)
	end)

	stackingTable = {}
	table.each(ctx.minions.minions, function(minion)
		local location = math.floor(minion.x)
		self:stackingTable(stackingTable, location, minion.width * 2, .5)
		self:health(minion.x - 25, h - ctx.environment.groundHeight - minion.height - 15 * stackingTable[location], minion.healthDisplay / minion.maxHealth, green, 50, 2)
	end)

	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local w2, h2 = w / 2, h / 2
		local x1, y1 = w2 - 300, h2 - 200
		local w, h = 600, 400
		g.setColor(50, 50, 50, self.upgradeAlpha * 240)
		g.rectangle('fill', 20, 20, love.graphics.getWidth() - 40, love.graphics.getHeight() - 40)
		
		g.setColor(255, 255, 255, self.upgradeAlpha * 240)

		for who in pairs(self.upgradePositions) do
			for what, geometry in pairs(self.upgradePositions[who]) do
				g.circle('line', unpack(geometry))
			end
		end

		if self.tooltip then
			local mx, my = love.mouse.getPosition()
			g.setColor(15, 15, 15, 230)
			local textWidth, lines = g.getFont():getWrap(self.tooltipRaw, 250)
			local xx = math.min(mx + 8, love.graphics.getWidth() - textWidth - 24)
			g.rectangle('fill', xx, my + 8, textWidth + 14, lines * g.getFont():getHeight() + 16 + 8)
			self.tooltip:draw(xx + 8, my + 16)
		end
	end

	g.setColor(255, 255, 255)
	g.draw(self.jujuIcon, 16, 16, 0, .75, .75)
	g.setColor(0, 0, 0)
	g.printf(math.floor(ctx.player.juju), 16, 16 + self.jujuIcon:getHeight() * .375 - (g.getFont():getHeight() / 2), self.jujuIcon:getWidth() * .75, 'center')
	g.setColor(255, 255, 255)
end

function Hud:keypressed(key)
	if (key == 'tab' or key == 'e') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
		self.upgrading = not self.upgrading
		return true
	end

	if key == 'escape' and self.upgrading then
		self.upgrading = false
	end
end

function Hud:keyreleased(key)

end

function Hud:mousepressed(x, y, b)
	if not self.upgrading then return end
	local w, h = love.graphics.getDimensions()
	local w2, h2 = w / 2, h / 2
	local x1, y1 = w2 - 300, h2 - 200
	local w, h = 600, 400
	if math.inside(x, y, w2 - 50, h2 + 216, 100, 40) then
		self.upgrading = false
	end
end

function Hud:mousereleased(x, y, b)
	if self.upgrading then
		local w, h = love.graphics.getDimensions()
		local w2, h2 = w / 2, h / 2
		local x1, y1 = w2 - 300, h2 - 200
		local w, h = 600, 400
		local xx

		xx = x1 + (w * .235)
		idx = 1
		for i = xx - 80, xx + 80, 78 do
			local yy = h2 - 144 + 80
			if idx == 1 or idx == 3 then yy = yy - 12 end
			if math.inside(x, y, i - 24, yy, 50, 50) then
				local key = ctx.upgrades.keys.zuju[idx]
				local cost = ctx.upgrades.costs.zuju[key][ctx.upgrades.zuju[key] + 1]
				if cost and ctx.player:spend(cost) then
					ctx.upgrades.zuju[key] = ctx.upgrades.zuju[key] + 1
					ctx.sound:play({sound = 'menuClick'})
				end
			end
			idx = idx + 1
		end

		xx = x1 + (w * .78)
		idx = 1
		for i = xx - 78, xx + 78, 78 do
			local yy = h2 - 144 + 80
			if idx == 1 or idx == 3 then yy = yy - 12 end
			if math.inside(x, y, i - 24, yy, 50, 50) then
				local key = ctx.upgrades.keys.vuju[idx]
				local cost = ctx.upgrades.costs.vuju[key][ctx.upgrades.vuju[key] + 1]
				if cost and ctx.player:spend(cost) then
					ctx.upgrades.vuju[key] = ctx.upgrades.vuju[key] + 1
					ctx.sound:play({sound = 'menuClick'})
				end
			end
			idx = idx + 1
		end

		xx = x1 + (w * .5)
		idx = 1
		for i = xx - 156, xx + 140, 138 do
			local yy = h2 + 16 + 70
			if idx == 1 or idx == 3 then yy = yy - 12 end
			if math.inside(x, y, i - 24, yy, 48, 48) then
				local key = ctx.upgrades.keys.muju[idx]
				local cost = ctx.upgrades.costs.muju[key][ctx.upgrades.muju[key] + 1]
				if cost and ctx.player:spend(cost) then
					ctx.upgrades.muju[key] = ctx.upgrades.muju[key] + 1
					ctx.sound:play({sound = 'menuClick'})
				end
			end
			idx = idx + 1
		end

		if #ctx.player.minions < 2 and math.inside(x, y, x1 + (w * .775) - 32, h2 - 144, 64, 64) then
			if ctx.player:spend(250) then
				table.insert(ctx.player.minions, Vuju)
				table.insert(ctx.player.minioncds, 0)
					ctx.sound:play({sound = 'menuClick'})
			end
		end
	end
end

