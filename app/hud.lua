Hud = class()

local g = love.graphics
local rich = require 'lib/deps/richtext/richtext'

local normalFont = love.graphics.newFont('media/fonts/inglobal.ttf', 14)
local fancyFont = love.graphics.newFont('media/fonts/inglobal.ttf', 24)
local boldFont = love.graphics.newFont('media/fonts/inglobalb.ttf', 14)
Hud.richOptions = {title = fancyFont, bold = boldFont, normal = normalFont, white = {255, 255, 255}, whoCares = {230, 230, 230}, red = {255, 100, 100}, green = {100, 255, 100}}
Hud.upgradePositions = {
	zuju = {
		empower = {161, 207, 28},
		fortify = {244, 212, 28},
		burst = {326, 208, 28},
		siphon = {193.5, 281, 32},
		sanctuary = {296, 281, 32}
	},
	vuju = {
		surge = {476, 208, 28},
		charge = {559, 212, 28},
		condemn = {641, 208, 28},
		arc = {508.5, 281, 32},
		soak = {611, 281, 32}
	},
	muju = {
		flow = {260, 406, 24},
		harvest = {218.5, 459.5, 26},
		refresh = {290, 478, 40},
		zeal = {400, 391, 20},
		absorb = {400, 442, 25},
		diffuse = {400, 507.5, 31},
		imbue = {537, 407, 24},
		mirror = {579, 461, 26},
		distort = {508, 478, 40}
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
	self.jujuIconScale = .75
	self.timer = {total = 0, minutes = 0, seconds = 0}
	self.particles = Particles()
	self.selectAlpha = {0, 0}
	self.cooldownAlpha = {.5, .5}
	self.selectBg = {g.newImage('media/graphics/select-zuju.png'), g.newImage('media/graphics/select-vuju.png')}
	ctx.view:register(self, 'gui')
end

function Hud:update()
	self.upgradeAlpha = math.lerp(self.upgradeAlpha, self.upgrading and 1 or 0, 12 * tickRate)
	self.jujuIconScale = math.lerp(self.jujuIconScale, .75, 12 * tickRate)
	for i = 1, #self.selectAlpha do
		self.selectAlpha[i] = math.lerp(self.selectAlpha[i], ctx.player.selectedMinion == i and 1 or .5, 5 * tickRate)
		self.cooldownAlpha[i] = math.lerp(self.cooldownAlpha[i], .5, 2 * tickRate)
	end

	-- Update Timer
	self:score()

	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local hover = false

		for who in pairs(self.upgradePositions) do
			for what, geometry in pairs(self.upgradePositions[who]) do
				if math.distance(mx, my, geometry[1], geometry[2]) < geometry[3] then
					local str = ctx.upgrades.makeTooltip(who, what)
					self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
					self.tooltipRaw = str:gsub('{%a+}', '')
					hover = true
					break
				end
			end
		end

		if math.distance(mx, my, 560, 140) < 38 then
			if #ctx.player.minions < 2 then
				local color = ctx.player.juju >= 80 and '{green}' or '{red}'
				local str = '{white}{title}Vuju{normal}\n{whoCares}Casts chain lightning and hexes enemies.\n\n' .. color .. '{bold}80 juju'
				self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
				self.tooltipRaw = str:gsub('{%a+}', '')
				hover = true
			else
				local str = '{white}{title}Vuju{normal}\nUnlocked!'
				self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
				self.tooltipRaw = str:gsub('{%a+}', '')
				hover = true
			end
		end

		if math.distance(mx, my, 245, 140) < 38 then
			local str = '{white}{title}Zuju{normal}\nUnlocked!'
			self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
			self.tooltipRaw = str:gsub('{%a+}', '')
			hover = true
		end

		if not hover then self.tooltip = nil end
	end

	self.particles:update()
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

	-- Vuju range indicator
	if ctx.player.recentSelect > 0 and ctx.player.selectedMinion == 2 then
		local range = 125 + ctx.upgrades.vuju.surge.level * 25
		g.setColor(255, 255, 255, 255 * math.min(ctx.player.recentSelect * 2, 1))
		local x, y = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), h - ctx.environment.groundHeight
		g.line(x - range, y, x + range, y)
	end

	-- Juju icon
	g.setFont(boldFont)
	if not self.upgrading then
		g.setColor(255, 255, 255, 255 * (1 - self.upgradeAlpha))
		g.draw(self.jujuIcon, 52, 55, 0, self.jujuIconScale, self.jujuIconScale, self.jujuIcon:getWidth() / 2, self.jujuIcon:getHeight() / 2)
		g.setColor(0, 0, 0)
		g.printf(math.floor(ctx.player.juju), 16, 18 + self.jujuIcon:getHeight() * .375 - (g.getFont():getHeight() / 2), self.jujuIcon:getWidth() * .75, 'center')
		g.setColor(255, 255, 255)
	end

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
	local str = self.timer.minutes .. ':' .. self.timer.seconds

	g.setColor(255, 255, 255)
	g.print(str, w - 25 - g.getFont():getWidth(str), 25)

	-- Minion indicator
	for i = 1, #ctx.player.minions do
		g.setColor(255, 210, 73, 255 * self.selectAlpha[i])
		local w = 123 + (180 * .05 * (self.cooldownAlpha[i] - .5))
		g.rectangle('fill', 64, 100 + 50 * (i - 1) + 10, w, 23)
		g.setColor(255, 255, 255, 255 * self.cooldownAlpha[i] * (self.selectAlpha[i]))
		local cd = ctx.player.minions[i].cooldown * (1 - (.1 * ctx.upgrades.muju.flow.level))
		g.rectangle('fill', 64, 100 + 50 * (i - 1) + 10, w * (1 - (ctx.player.minioncds[i] / cd)), 23)
		g.setColor(255, 255, 255, self.selectAlpha[i] * 255)
		g.draw(self.selectBg[i], 16, 100 + 50 * (i - 1), 0, .6 + (.05 * (self.cooldownAlpha[i] - .5)), .6)
		g.setColor(0, 0, 0, self.selectAlpha[i] * 255)
		g.print(ctx.player.minions[i].code:capitalize(), 80, 100 + 50 * (i - 1) + 14)
	end
	g.setColor(ctx.player.selectedMinion == 1 and {255, 255, 255} or {150, 150, 150})
	local upgradeCount = ctx.upgrades.zuju.empower.level + ctx.upgrades.zuju.fortify.level + ctx.upgrades.zuju.burst.level + ctx.upgrades.zuju.siphon.level + ctx.upgrades.zuju.sanctuary.level
	local zujucost = Zuju.cost + (3 * upgradeCount)
	upgradeCount = ctx.upgrades.vuju.surge.level + ctx.upgrades.vuju.charge.level + ctx.upgrades.vuju.condemn.level + ctx.upgrades.vuju.arc.level + ctx.upgrades.vuju.soak.level
	local vujucost = Vuju.cost + (4 * upgradeCount)
	g.print('Zuju [' .. math.round(zujucost) .. '] ' .. (ctx.player.minioncds[1] > 0 and math.ceil(ctx.player.minioncds[1]) or ''), 200, 115)
	if #ctx.player.minions == 2 then
		g.setColor(ctx.player.selectedMinion == 2 and {255, 255, 255} or {150, 150, 150})
		local cost = Vuju.cost
		local upgradeCount = 0
		g.print('Vuju [' .. math.round(vujucost) .. '] ' .. (ctx.player.minioncds[2] > 0 and math.ceil(ctx.player.minioncds[2]) or ''), 200, 115 + g.getFont():getHeight() + 2)
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

	-- Upgrade screen
	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local w2, h2 = w / 2, h / 2
		
		g.setColor(255, 255, 255, self.upgradeAlpha * 250)
		g.draw(self.upgradeBg, 400, 300, 0, .875, .875, self.upgradeBg:getWidth() / 2, self.upgradeBg:getHeight() / 2)

		g.setColor(0, 0, 0, self.upgradeAlpha * 250)
		local str = tostring(math.floor(ctx.player.juju))
		g.print(str, w2 - g.getFont():getWidth(str) / 2, 65)

		if self.tooltip then
			local mx, my = love.mouse.getPosition()
			local textWidth, lines = normalFont:getWrap(self.tooltipRaw, 300)
			local xx = math.min(mx + 8, love.graphics.getWidth() - textWidth - 24)
			local yy = math.min(my + 8, love.graphics.getHeight() - (lines * g.getFont():getHeight() + 16 + 7))
			g.setColor(30, 50, 70, 240)
			g.rectangle('fill', xx, yy, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
			g.setColor(10, 30, 50, 255)
			g.rectangle('line', xx + .5, yy + .5, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
			self.tooltip:draw(xx + 8, yy + 4)
		end
	end
end

function Hud:keypressed(key)
	if (key == 'tab' or key == 'e') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
		self.upgrading = not self.upgrading
		return true
	end

	if key == 'v' and #ctx.player.minions < 2 and ctx.player:spend(80) then
	end

	if key == 'escape' and self.upgrading then
		self.upgrading = false
	end
end

function Hud:keyreleased(key)
	--
end

function Hud:gamepadpressed(gamepad, button)
	if gamepad == ctx.player.gamepad then
		if (button == 'x' or button == 'y') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
			self.upgrading = not self.upgrading
			return true
		end
	end
end

function Hud:mousepressed(x, y, b)
	if not self.upgrading then return end
	if math.inside(x, y, 69, 94, 50, 50) then
		self.upgrading = false
	end
end

function Hud:mousereleased(x, y, b)
	if self.upgrading and b == 'l' then
		for who in pairs(self.upgradePositions) do
			for what, geometry in pairs(self.upgradePositions[who]) do
				if math.distance(x, y, geometry[1], geometry[2]) < geometry[3] then
					local upgrade = ctx.upgrades[who][what]
					local nextLevel = upgrade.level + 1
					local cost = upgrade.costs[nextLevel]

					if ctx.upgrades.canBuy(who, what) and ctx.player:spend(cost) then
						ctx.upgrades[who][what].level = nextLevel
						ctx.sound:play({sound = 'menuClick'})
						for i = 1, 80 do
							self.particles:add(UpgradeParticle, {x = x, y = y})
						end
					end
				end
			end
		end

		if #ctx.player.minions < 2 and math.distance(x, y, 560, 140) < 38 and ctx.player:spend(80) then
			table.insert(ctx.player.minions, Vuju)
			table.insert(ctx.player.minioncds, 0)
			for i = 1, 100 do
				self.particles:add(UpgradeParticle, {x = x, y = y})
			end
		end
	end
end
