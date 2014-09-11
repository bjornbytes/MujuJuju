Hud = class()

local g = love.graphics
local rich = require 'lib/deps/richtext/richtext'

local normalFont = love.graphics.newFont('media/fonts/inglobal.ttf', 14)
local fancyFont = love.graphics.newFont('media/fonts/inglobal.ttf', 24)
local boldFont = love.graphics.newFont('media/fonts/inglobalb.ttf', 14)
Hud.richOptions = {title = fancyFont, bold = boldFont, normal = normalFont, white = {255, 255, 255}, whoCares = {230, 230, 230}, red = {255, 100, 100}, green = {100, 255, 100}}
Hud.upgradeGeometry = {
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
Hud.upgradeDotGeometry = {
	zuju = {
		empower = {{139, 229, 7}, {149, 235, 7}, {160, 238, 7}, {171, 235, 7}, {181, 229, 7}},
		fortify = {{223, 233, 7}, {233, 239, 7}, {244, 241, 7}, {255, 239, 7}, {265, 233, 7}},
		burst = {{304, 229, 7}, {314, 235, 7}, {325, 238, 7}, {336, 235, 7}, {346, 229, 7}},
		siphon = {{177, 308, 9}, {193, 312, 9}, {209, 308, 9}},
		sanctuary = {{280, 308, 9}, {296, 312, 9}, {312, 308, 9}}
	},
	vuju = {
		surge = {{454, 229, 7}, {464, 235, 7}, {475, 238, 7}, {486, 235, 7}, {496, 229, 7}},
		charge = {{538, 233, 7}, {548, 239, 7}, {559, 241, 7}, {570, 239, 7}, {580, 233, 7}},
		condemn = {{619, 229, 7}, {629, 235, 7}, {640, 238, 7}, {651, 235, 7}, {661, 229, 7}},
		arc = {{492, 308, 9}, {508, 312, 9}, {524, 308, 9}},
		soak = {{595, 308, 9}, {611, 312, 9}, {627, 308, 9}}
	},
	muju = {
		zeal = {{386.5, 402.5, 4}, {392.5, 406.5, 4}, {399.5, 407.5, 4}, {406.5, 406.5, 4}, {412.5, 402.5, 4}}
	}
}

function Hud:init()
	self.upgrading = false
	self.upgradeBg = g.newImage('media/graphics/upgrade-menu.png')
	self.upgradeDot = g.newImage('media/graphics/level-icon.png')
	self.upgradeDotAlpha = {}
	self.lock = g.newImage('media/graphics/lock.png')
	self.upgradeAlpha = 0
	self.tooltip = nil
	self.tooltipRaw = ''
	self.jujuIcon = g.newImage('media/graphics/juju-icon.png')
	self.jujuIconScale = .75
	self.timer = {total = 0, minutes = 0, seconds = 0}
	self.particles = Particles()
	self.selectBg = {g.newImage('media/graphics/select-zuju.png'), g.newImage('media/graphics/select-vuju.png')}
	self.selectFactor = {0, 0}
	self.selectExtra = {0, 0}
	self.selectQuad = {}
	self.selectQuad[1] = g.newQuad(0, 0, self.selectBg[1]:getWidth(), self.selectBg[1]:getHeight(), self.selectBg[1]:getWidth(), self.selectBg[1]:getHeight())
	self.selectQuad[2] = g.newQuad(0, 0, self.selectBg[2]:getWidth(), self.selectBg[2]:getHeight(), self.selectBg[2]:getWidth(), self.selectBg[2]:getHeight())
	self.deadAlpha = 0
	ctx.view:register(self, 'gui')
end

function Hud:update()
	self.upgradeAlpha = math.lerp(self.upgradeAlpha, self.upgrading and 1 or 0, 12 * tickRate)
	self.deadAlpha = math.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * tickRate)
	self.jujuIconScale = math.lerp(self.jujuIconScale, .75, 12 * tickRate)
	for i = 1, #self.selectFactor do
		self.selectFactor[i] = math.lerp(self.selectFactor[i], ctx.player.selectedMinion == i and 1 or 0, 18 * tickRate)
		self.selectExtra[i] = math.lerp(self.selectExtra[i], 0, 5 * tickRate)
		if ctx.player.minions[i] then
			local y = self.selectBg[i]:getHeight() * (ctx.player.minioncds[i] / ctx.player.minions[i].cooldown)
			self.selectQuad[i]:setViewport(0, y, self.selectBg[i]:getWidth(), self.selectBg[i]:getHeight() - y)
		end
	end

	-- Update Timer
	self:score()

	for key in pairs(self.upgradeDotAlpha) do
		self.upgradeDotAlpha[key] = math.lerp(self.upgradeDotAlpha[key], 1, 5 * tickRate)
		if self.upgradeDotAlpha[key] > .999 then
			self.upgradeDotAlpha[key] = nil
		end
	end

	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local hover = false

		for who in pairs(self.upgradeGeometry) do
			for what, geometry in pairs(self.upgradeGeometry[who]) do
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
	local yy = 135
	for i = 1, #ctx.player.minions do
		local bg = self.selectBg[i]
		local scale = .75 + (.15 * self.selectFactor[i]) + (.1 * self.selectExtra[i])
		local xx = 48 - 10 * (1 - self.selectFactor[i])
		local f, cost = g.getFont(), tostring(ctx.player.minions[i]:getCost())
		local tx, ty = xx - f:getWidth(cost) / 2, yy - f:getHeight() / 2
		local alpha = .65 + self.selectFactor[i] * .35

		-- Backdrop
		g.setColor(255, 255, 255, 80 * alpha)
		g.draw(bg, xx, yy, 0, scale, scale, bg:getWidth() / 2, bg:getHeight() / 2)

		-- Cooldown
		local _, qy = self.selectQuad[i]:getViewport()
		g.setColor(255, 255, 255, (150 + (100 * (ctx.player.minioncds[i] == 0 and 1 or 0))) * alpha)
		g.draw(bg, self.selectQuad[i], xx, yy + qy * scale, 0, scale, scale, bg:getWidth() / 2, bg:getHeight() / 2)

		-- Juice
		g.setBlendMode('additive')
		g.setColor(255, 255, 255, 60 * self.selectExtra[i])
		g.draw(bg, xx, yy, 0, scale + .2 * self.selectExtra[i], scale + .2 * self.selectExtra[i], bg:getWidth() / 2, bg:getHeight() / 2)
		g.setBlendMode('alpha')

		-- Cost
		g.setColor(0, 0, 0, 200 + 55 * self.selectFactor[i])
		g.print(cost, tx + 1, ty + 1)
		g.setColor(255, 255, 255, 200 + 55 * self.selectFactor[i])
		g.print(cost, tx, ty)
		yy = yy + self.selectBg[i]:getHeight() * 1
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
	if self.upgradeAlpha > .001 and not ctx.ded then
		local mx, my = love.mouse.getPosition()
		local w2, h2 = w / 2, h / 2
		
		g.setColor(255, 255, 255, self.upgradeAlpha * 250)
		g.draw(self.upgradeBg, 400, 300, 0, .875, .875, self.upgradeBg:getWidth() / 2, self.upgradeBg:getHeight() / 2)

		g.setColor(0, 0, 0, self.upgradeAlpha * 250)
		local str = tostring(math.floor(ctx.player.juju))
		g.print(str, w2 - g.getFont():getWidth(str) / 2, 65)

		for who in pairs(self.upgradeDotGeometry) do
			for what in pairs(self.upgradeDotGeometry[who]) do
				for i = 1, ctx.upgrades[who][what].level do
					local info = self.upgradeDotGeometry[who][what][i]
					if info then
						local x, y, scale = unpack(info)
						local dot = self.upgradeDot
						local w, h = dot:getDimensions()
						g.setColor(255, 255, 255, (self.upgradeDotAlpha[who .. what .. i] or 1) * 255 * self.upgradeAlpha)
						g.draw(dot, x + .5, y + .5, 0, scale / w, scale / h, w / 2, h / 2)
					end
				end
			end
		end

		g.setColor(255, 255, 255, 220 * self.upgradeAlpha)
		local lw, lh = self.lock:getDimensions()
		for who in pairs(self.upgradeGeometry) do
			for what, geometry in pairs(self.upgradeGeometry[who]) do
				if not ctx.upgrades.checkPrerequisites(who, what) then
					local scale = math.min(geometry[3] / lw, geometry[3] / lh) + .1
					g.draw(self.lock, geometry[1], geometry[2], 0, scale, scale, lw / 2, lh / 2)
				end
			end
		end

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

	-- Death Screen
	if ctx.ded then
		g.setColor(255, 255, 255, 255 * self.deadAlpha)
		local str = 'u ded'
		g.print(str, g.getWidth() / 2 - g.getFont():getWidth(str) / 2, g.getHeight() / 2)
	end
end

function Hud:keypressed(key)
	if (key == 'tab' or key == 'e') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width and not ctx.ded then
		self.upgrading = not self.upgrading
		return true
	end

	if key == 'escape' and self.upgrading and not ctx.ded then
		self.upgrading = false
	end

	if ctx.ded and self.deadAlpha > .9 then
		Context:remove(ctx)
		Context:add(Game)
	end
end

function Hud:keyreleased(key)
	--
end

function Hud:gamepadpressed(gamepad, button)
	if gamepad == ctx.player.gamepad and not ctx.ded then
		if (button == 'x' or button == 'y') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
			self.upgrading = not self.upgrading
			return true
		end
	end

	if ctx.ded and self.deadAlpha > .9 then
		Context:remove(ctx)
		Context:add(Game)
	end
end

function Hud:mousepressed(x, y, b)
	if not self.upgrading or ctx.ded then return end
	if math.inside(x, y, 69, 94, 50, 50) then
		self.upgrading = false
	end
end

function Hud:mousereleased(x, y, b)
	if self.upgrading and b == 'l' and not ctx.ded then
		for who in pairs(self.upgradeGeometry) do
			for what, geometry in pairs(self.upgradeGeometry[who]) do
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
						self.upgradeDotAlpha[who .. what .. nextLevel] = 0
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

	if ctx.ded and self.deadAlpha > .9 then
		Context:remove(ctx)
		Context:add(Game)
	end
end
