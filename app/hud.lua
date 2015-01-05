Hud = class()

local g = love.graphics
local rich = require 'lib/deps/richtext/richtext'

local normalFont = love.graphics.newFont('media/fonts/inglobal.ttf', 14)
local fancyFont = love.graphics.newFont('media/fonts/inglobal.ttf', 24)
local boldFont = love.graphics.newFont('media/fonts/inglobalb.ttf', 14)
local deadFontBig = love.graphics.newFont('media/fonts/inglobal.ttf', 64)
local deadFontSmall = love.graphics.newFont('media/fonts/inglobal.ttf', 44)
Hud.richOptions = {
  title = g.setFont('mesmerize', 24),
  bold = g.setFont('mesmerize', 14),
  normal = g.setFont('mesmerize', 14),
  white = {255, 255, 255},
  whoCares = {230, 230, 230},
  red = {255, 100, 100},
  green = {100, 255, 100},
  purple = {115, 75, 150}
}

function Hud:init()
	self.cursorImage = g.newImage('media/graphics/cursor.png')
	self.cursorX = g.getWidth() / 2
	self.cursorY = g.getHeight() / 2
	self.prevCursorX = self.cursorX
	self.prevCursorY = self.cursorY
	self.cursorSpeed = 0
	self.upgrading = false
	self.upgradeBg = data.media.graphics.upgradeMenu
	self.upgradeCircles = data.media.graphics.upgradeMenuCircles
	self.upgradeDot = data.media.graphics.levelIcon
	self.upgradeDotAlpha = {}
	self.lock = data.media.graphics.lock
	self.upgradeAlpha = 0
	self.upgradesBought = 0
	self.tooltip = nil
	self.tooltipRaw = ''
	self.jujuIcon = data.media.graphics.juju
	self.jujuIconScale = .75
	self.timer = {total = 0, minutes = 0, seconds = 0}
	self.particles = Particles()
	self.selectBg = {data.media.graphics.unit.portrait.bruju, data.media.graphics.unit.portrait.huju, data.media.graphics.unit.portrait.huju}
	self.selectFactor = {0, 0, 0}
	self.selectExtra = {0, 0, 0}
	self.selectQuad = {}
	self.selectQuad[1] = g.newQuad(0, 0, self.selectBg[1]:getWidth(), self.selectBg[1]:getHeight(), self.selectBg[1]:getWidth(), self.selectBg[1]:getHeight())
	self.selectQuad[2] = g.newQuad(0, 0, self.selectBg[2]:getWidth(), self.selectBg[2]:getHeight(), self.selectBg[2]:getWidth(), self.selectBg[2]:getHeight())
	self.selectQuad[3] = g.newQuad(0, 0, self.selectBg[3]:getWidth(), self.selectBg[3]:getHeight(), self.selectBg[3]:getWidth(), self.selectBg[3]:getHeight())
	self.deadAlpha = 0
	self.deadName = ''
	self.deadNameFrame = data.media.graphics.deathBox
	self.deadOk = data.media.graphics.deathOk
	self.deadReplay = data.media.graphics.deathQuit
	self.deadQuit = data.media.graphics.deathReplay
	self.deadScreen = 1
	self.pauseAlpha = 0
	self.pauseScreen = data.media.graphics.pauseMenu
	self.protectAlpha = 3
  self.u, self.v = love.graphics.getDimensions()
  self.health = HudHealth()
  self.upgrades = HudUpgrades()
  self.units = HudUnits()
  self.shrujuPatches = {HudShrujuPatch(), HudShrujuPatch()}
  self.shruju = HudShruju()
  self.tooltipHover = false
	love.filesystem.write('playedBefore', 'achievement unlocked.')
	ctx.view:register(self, 'gui')
end

function Hud:update()
  local p = ctx.players:get(ctx.id)

  self.tooltipHover = false
	self.upgradeAlpha = math.lerp(self.upgradeAlpha, self.upgrading and 1 or 0, 12 * tickRate)
	self.deadAlpha = math.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * tickRate)
	self.pauseAlpha = math.lerp(self.pauseAlpha, ctx.paused and 1 or 0, 12 * tickRate)
	self.protectAlpha = math.max(self.protectAlpha - tickRate, 0)
	self.jujuIconScale = math.lerp(self.jujuIconScale, .75, 12 * tickRate)

  self.upgrades:update()
  self.shruju:update()
  self.units:update()
  table.with(self.shrujuPatches, 'update')

	-- Update Timer
	self:score()
	
	-- Virtual cursor for upgrades
	if p.gamepad then
		local vx, vy = 0, 0
		local xx, yy = p.gamepad:getGamepadAxis('leftx'), p.gamepad:getGamepadAxis('lefty')
		local cursorSpeed = 500
		local len = (xx * xx + yy * yy) ^ .5
		self.prevCursorX = self.cursorX
		self.prevCursorY = self.cursorY
		self.cursorSpeed = math.lerp(self.cursorSpeed, len > .2 and cursorSpeed or 0, 18 * tickRate)
		len = len ^ 4
		vx = xx / len
		vy = yy / len
		vx = math.clamp(vx, -1, 1)
		vy = math.clamp(vy, -1, 1)
		vx = vx * self.cursorSpeed * len
		vy = vy * self.cursorSpeed * len
		self.cursorX = self.cursorX + vx * tickRate
		self.cursorY = self.cursorY + vy * tickRate
  else
    self.prevCursorX = self.cursorX
    self.prevCursorY = self.cursorY
    self.cursorX = math.lerp(self.cursorX, love.mouse.getX(), 8 * tickRate)
    self.cursorY = math.lerp(self.cursorY, love.mouse.getY(), 8 * tickRate)
  end

	for key in pairs(self.upgradeDotAlpha) do
		self.upgradeDotAlpha[key] = math.lerp(self.upgradeDotAlpha[key], 1, 5 * tickRate)
		if self.upgradeDotAlpha[key] > .999 then
			self.upgradeDotAlpha[key] = nil
		end
	end

	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local hover = false

		if p.gamepad then
			mx, my = self.cursorX, self.cursorY
		end

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
			if #p.deck < 2 then
				local color = p.juju >= 80 and '{green}' or '{red}'
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

	if ctx.ded then love.keyboard.setKeyRepeat(true) end

  if not self.tooltipHover then self.tooltip = nil end
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
	if not self.upgrading and not ctx.paused and not ctx.ded then
		self.timer.total = self.timer.total + 1
	end
end

function Hud:gui()
	local w, h = love.graphics.getDimensions()
  local p = ctx.players:get(ctx.id)

	if not ctx.ded then

		-- Juju icon
		g.setFont(boldFont)
		if not self.upgrading then
			g.setColor(255, 255, 255, 255 * (1 - self.upgradeAlpha))
			g.draw(self.jujuIcon, 52, 55, 0, self.jujuIconScale, self.jujuIconScale, self.jujuIcon:getWidth() / 2, self.jujuIcon:getHeight() / 2)
			g.setColor(0, 0, 0)
			g.printf(math.floor(p.juju), 16, 18 + self.jujuIcon:getHeight() * .375 - (g.getFont():getHeight() / 2), self.jujuIcon:getWidth() * .75, 'center')
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

    local pop = p:getPopulation()
    g.print(pop .. ' / ' .. p.maxPopulation, w - 25 - g.getFont():getWidth(str), 50)

    self.health:draw()

    table.with(self.shrujuPatches, 'draw')
    self.shruju:draw()

		-- Protect message
		if self.protectAlpha > .1 then
			g.setFont(deadFontBig)
			g.setColor(0, 0, 0, 150 * math.min(self.protectAlpha, 1))
			g.printf('Protect Your Shrine!', 2, h * .25 + 2, w, 'center')
			g.setColor(253, 238, 65, 255 * math.min(self.protectAlpha, 1))
			g.printf('Protect Your Shrine!', 0, h * .25, w, 'center')
			g.setFont(boldFont)
		end

		-- Pause Menu
		if self.pauseAlpha > .01 then
			g.setColor(0, 0, 0, 128 * self.pauseAlpha)
			g.rectangle('fill', 0, 0, g.getDimensions())

			g.setColor(255, 255, 255, 255 * self.pauseAlpha)
			g.draw(self.pauseScreen, w * .5, h * .5, 0, 1, 1, self.pauseScreen:getWidth() / 2, self.pauseScreen:getHeight() / 2)
		end
	end

  self.units:draw()

	-- Upgrade screen
	if self.upgradeAlpha > .001 and not ctx.ded then
		local mx, my = love.mouse.getPosition()
		local w2, h2 = w / 2, h / 2
		
		g.setColor(255, 255, 255, self.upgradeAlpha * 250)
		g.draw(self.upgradeBg, 400, 300, 0, .875, .875, self.upgradeBg:getWidth() / 2, self.upgradeBg:getHeight() / 2)

		g.setColor(255, 255, 255, self.upgradeAlpha * 250)
		g.draw(self.upgradeCircles, 400, 300, 0, 1, 1, self.upgradeCircles:getWidth() / 2, self.upgradeCircles:getHeight() / 2)

		g.setColor(0, 0, 0, self.upgradeAlpha * 250)
		local str = tostring(math.floor(p.juju))
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
	end

  if self.tooltip then
    mx, my = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate), math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
    g.setFont(self.richOptions.normal)
    local textWidth, lines = normalFont:getWrap(self.tooltipRaw, 300)
    local xx = math.min(mx + 8, love.graphics.getWidth() - textWidth - 24)
    local yy = math.min(my + 8, love.graphics.getHeight() - (lines * g.getFont():getHeight() + 16 + 7))
    g.setColor(30, 50, 70, 240)
    g.rectangle('fill', xx, yy, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
    g.setColor(10, 30, 50, 255)
    g.rectangle('line', xx + .5, yy + .5, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
    self.tooltip:draw(xx + 8, yy + 4)
  end

	-- Death Screen
	if ctx.ded then
		if false and self.deadScreen == 1 then
			g.setColor(244, 188, 80, 255 * self.deadAlpha)
			g.setFont(deadFontBig)
			local str = 'YOUR SHRINE HAS BEEN DESTROYED!'
			g.printf(str, .0625 * self.u, 30, .875 * self.u, 'center')

			g.setColor(253, 238, 65, 255 * self.deadAlpha)
			g.setFont(deadFontSmall)
			str = 'Your Score:'
			g.printf(str, 0, h * .325, w, 'center')

			g.setColor(240, 240, 240, 255 * self.deadAlpha)
			str = tostring(math.floor(self.timer.total * tickRate))
      local benchmark
      if math.floor(self.timer.total * tickRate) >= config.biomes[ctx.biome].benchmarks.gold then
        benchmark = 'Gold'
      elseif math.floor(self.timer.total * tickRate) >= config.biomes[ctx.biome].benchmarks.silver then
        benchmark = 'Silver'
      elseif math.floor(self.timer.total * tickRate) >= config.biomes[ctx.biome].benchmarks.bronze then
        benchmark = 'Bronze'
      end

      if benchmark then str = str .. ' (' .. benchmark .. ')' end
			g.printf(str, 0, h * .41, w, 'center')
			
			g.setColor(253, 238, 65, 255 * self.deadAlpha)
			str = 'Your Name:'
			g.printf(str, 0, h * .51, w, 'center')

			g.setColor(255, 255, 255, 255 * self.deadAlpha)
			g.draw(self.deadNameFrame, w / 2 - self.deadNameFrame:getWidth() / 2, h * .584)
			
			g.setColor(240, 240, 240, 255 * self.deadAlpha)
			local font = g.getFont()
			local scale = 1
			while font:getWidth(self.deadName) * scale > self.deadNameFrame:getWidth() - 24 do scale = scale - .05 end
			
			local xx = w / 2 - font:getWidth(self.deadName) * scale / 2
			local yy = h * .584 + (self.deadNameFrame:getHeight() / 2) - font:getHeight() * scale / 2
			g.print(self.deadName, xx, yy, 0, scale, scale)

			local cursorx = xx + font:getWidth(self.deadName) * scale + 1
			g.line(cursorx, yy, cursorx, yy + font:getHeight() * scale)

			g.setColor(255, 255, 255, 255 * self.deadAlpha)
			g.draw(self.deadOk, w / 2 - self.deadOk:getWidth() / 2, h * .825)
		else
			if false and self.highscores then
				g.setColor(253, 238, 65, 255 * self.deadAlpha)
				g.setFont(deadFontSmall)
				g.printf('Highscores', 0, h * .05, w, 'center')

				g.setFont(fancyFont)
				g.setColor(255, 255, 255, 255 * self.deadAlpha)
				local yy = h * .2

				for _, entry in ipairs(self.highscores) do
					g.print(entry.who, w * .3, yy)
					g.printf(entry.what, 0, yy, w * .7, 'right')
					yy = yy + g.getFont():getHeight() + 4
				end
				
				g.draw(self.deadReplay, w * .4, h * .825, 0, 1, 1, self.deadReplay:getWidth() / 2)
				g.draw(self.deadQuit, w * .6, h * .825, 0, 1, 1, self.deadQuit:getWidth() / 2)
			else
        g.setFont(deadFontSmall)
        str = 'Your Score:'
        g.printf(str, 0, h * .325, w, 'center')

        g.setColor(240, 240, 240, 255 * self.deadAlpha)
        str = tostring(math.floor(self.timer.total * tickRate))
        local benchmark
        if math.floor(self.timer.total * tickRate) >= config.biomes[ctx.biome].benchmarks.gold then
          benchmark = 'Gold'
        elseif math.floor(self.timer.total * tickRate) >= config.biomes[ctx.biome].benchmarks.silver then
          benchmark = 'Silver'
        elseif math.floor(self.timer.total * tickRate) >= config.biomes[ctx.biome].benchmarks.bronze then
          benchmark = 'Bronze'
        end

        if benchmark then str = str .. ' (' .. benchmark .. ')' end
        g.printf(str, 0, h * .41, w, 'center')

				g.draw(self.deadReplay, w * .4, h * .825, 0, 1, 1, self.deadReplay:getWidth() / 2)
				g.draw(self.deadQuit, w * .6, h * .825, 0, 1, 1, self.deadQuit:getWidth() / 2)
			end
		end
	end

	if self.upgrading or ctx.paused or ctx.ded then
		if p.gamepad then
			local xx, yy = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate), math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
			g.setColor(255, 255, 255)
			g.draw(self.cursorImage, xx, yy)
		end
	end
end

function Hud:keypressed(key)
  table.with(self.shrujuPatches, 'keypressed', key)
  self.upgrades:keypressed(key)

	--[[if (key == 'tab' or key == 'e') and math.abs(p.x - ctx.shrine.x) < p.width and not ctx.ded then
		self.upgrading = not self.upgrading
		return true
	end]]

	--[[if key == 'escape' and self.upgrading and not ctx.ded then
		self.upgrading = false
	end]]

	if ctx.ded and self.deadAlpha > .9 then
		if key == 'escape' then
			Context:remove(ctx)
      local biomeIndex = nil
      for i = 1, #config.biomeOrder do
        if config.biomeOrder[i] == ctx.biome then biomeIndex = i break end
      end
			Context:add(Menu, biomeIndex)
		end
	end
end

function Hud:keyreleased(key)
	--
end

function Hud:textinput(char)
	if ctx.ded then
		if #self.deadName < 16 and char:match('%w') then
			self.deadName = self.deadName .. char
		end
	end
end

function Hud:gamepadpressed(gamepad, button)
  local p = ctx.players:get(ctx.id)
	if gamepad == p.gamepad and not ctx.ded then
		if (button == 'x' or button == 'y') and math.abs(p.x - ctx.shrine.x) < p.width then
			self.upgrading = not self.upgrading
			self.cursorX = g.getWidth() / 2
			self.cursorY = g.getHeight() / 2
			self.prevCursorX = self.cursorX
			self.prevCursorY = self.cursorY
			return true
		end
		if button == 'a' and (self.upgrading or ctx.paused or ctx.ded) then
			self:mousepressed(self.cursorX, self.cursorY, 'l')
			self:mousereleased(self.cursorX, self.cursorY, 'l')
		end
	end
end

function Hud:mousepressed(x, y, b)
  self.shruju:mousepressed(x, y, b)
  table.with(self.shrujuPatches, 'mousepressed', x, y, b)
	if not self.upgrading or ctx.ded then return end
	if math.inside(x, y, 670, 502, 48, 48) then
		self.upgrading = false
	end
end

function Hud:mousereleased(x, y, b)
  local p = ctx.players:get(ctx.id)
  if self.upgrades.active then
    self.units:mousereleased(x, y, b)
  end

	if b == 'l' and ctx.ded then
		if false and self.deadScreen == 1 then
			local img = self.deadOk
			local w2 = g.getWidth() / 2
			if math.inside(x, y, w2 - img:getWidth() / 2, g.getHeight() * .825, img:getDimensions()) then
				self:sendScore()
			end
		elseif true or self.deadScreen == 2 then
			local img1 = self.deadReplay
			local img2 = self.deadQuit
			local w = g.getWidth()
			local h = g.getHeight()
			if math.inside(x, y, w * .4 - img1:getWidth() / 2, h * .825, img1:getDimensions()) then
				Context:remove(ctx)
        local biomeIndex = nil
        for i = 1, #config.biomeOrder do
          if config.biomeOrder[i] == ctx.biome then biomeIndex = i break end
        end
				Context:add(Menu, biomeIndex)
			elseif math.inside(x, y, w * .6 - img2:getWidth() / 2, h * .825, img2:getDimensions()) then
				Context:remove(ctx)
				Context:add(Game, ctx.user, ctx.biome)
			end
		end
	end

	if b == 'l' and ctx.paused then
		local w, h = g.getDimensions()
		if math.inside(x, y, w * .4, h * .4, 155, 60) then
			ctx.paused = not ctx.paused
		elseif math.inside(x, y, w * .4, h * .51, 155, 60) then
			Context:remove(ctx)
			Context:add(Menu)
		end
	end
end

function Hud:sendScore()
	self.highscores = nil

	if #self.deadName > 0 then
		local seconds = math.floor(self.timer.total * tickRate)
		local http = require('socket.http')
		http.TIMEOUT = 5
		local response = http.request('http://plasticsarcastic.com/mujuJuju/score.php?name=' .. self.deadName .. '&score=' .. seconds)
		if response then
			self.highscores = {}
			for who, what, when in response:gmatch('(%w+)%,(%w+)%,(%w+)') do
				table.insert(self.highscores, {who = who, what = what, when = when})
			end
		end
	end

	self.deadScreen = 2
end
