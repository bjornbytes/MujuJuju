Hud = class()
Hud.depth = -100

local g = love.graphics

local normalFont = love.graphics.newFont('media/fonts/inglobal.ttf', 14)
local fancyFont = love.graphics.newFont('media/fonts/inglobal.ttf', 24)
local boldFont = love.graphics.newFont('media/fonts/inglobalb.ttf', 14)
local deadFontBig = love.graphics.newFont('media/fonts/inglobal.ttf', 64)
local deadFontSmall = love.graphics.newFont('media/fonts/inglobal.ttf', 44)

function Hud:init()
	self.tooltip = nil
	self.tooltipRaw = ''
  self.deadAlpha = 0
	self.deadReplay = data.media.graphics.deathQuit
	self.deadQuit = data.media.graphics.deathReplay
	self.pauseAlpha = 0
	self.pauseScreen = data.media.graphics.pauseMenu
	self.protectAlpha = 3

  self.u, self.v = love.graphics.getDimensions()
  self.health = HudHealth()
  self.upgrades = HudUpgrades()
  self.units = HudUnits()
  self.shrujuPatches = {HudShrujuPatch(), HudShrujuPatch()}
  self.shruju = HudShruju()
  self.status = HudStatus()
  self.tooltip = Tooltip()
  
	love.filesystem.write('playedBefore', 'achievement unlocked.')
	ctx.view:register(self, 'gui')
end

function Hud:update()
  local p = ctx.players:get(ctx.id)

	self.deadAlpha = math.lerp(self.deadAlpha, ctx.ded and 1 or 0, 12 * tickRate)
	self.pauseAlpha = math.lerp(self.pauseAlpha, ctx.paused and 1 or 0, 12 * tickRate)
	self.protectAlpha = math.max(self.protectAlpha - tickRate, 0)

  self.tooltip:update()
  self.status:update()
  self.health:update()
  self.upgrades:update()
  self.shruju:update()
  self.units:update()
  table.with(self.shrujuPatches, 'update')

	if ctx.ded then love.keyboard.setKeyRepeat(true) end
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

function Hud:gui()
	local w, h = love.graphics.getDimensions()
  local u, v = self.u, self.v
  local p = ctx.players:get(ctx.id)

	if not ctx.ded then

    self.status:draw()
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

	-- Death Screen
	if ctx.ded then
    g.setFont(deadFontSmall)
    str = 'Your Score:'
    g.printf(str, 0, h * .225, w, 'center')

    g.setColor(240, 240, 240, 255 * self.deadAlpha)
    str = tostring(math.floor(ctx.timer * tickRate))
    local benchmark
    local timer = math.floor(ctx.timer * tickRate)
    if timer >= config.biomes[ctx.biome].benchmarks.gold then benchmark = 'Gold'
    elseif timer >= config.biomes[ctx.biome].benchmarks.silver then benchmark = 'Silver'
    elseif timer >= config.biomes[ctx.biome].benchmarks.bronze then benchmark = 'Bronze' end

    if benchmark then str = str .. ' (' .. benchmark .. ')' end
    g.printf(str, 0, h * .31, w, 'center')

    local rewards = 'Cool Stuff:'
    if ctx.rewards.highscore then rewards = rewards .. '\nNew highscore!' end
    if #ctx.rewards.runes > 0 then 
      local names = table.map(ctx.rewards.runes, function(rune) return rune.name end)
      rewards = rewards .. '\n' .. table.concat(names, ', ')
    end

    if #ctx.rewards.biomes > 0 then
      rewards = rewards .. '\n' .. table.concat(ctx.rewards.biomes, ', ')
    end

    if #ctx.rewards.minions > 0 then
      rewards = rewards .. '\n' .. table.concat(ctx.rewards.minions, ', ')
    end

    g.printf(rewards, 0, h * .4, w, 'center')

    g.draw(self.deadReplay, w * .4, h * .825, 0, 1, 1, self.deadReplay:getWidth() / 2)
    g.draw(self.deadQuit, w * .6, h * .825, 0, 1, 1, self.deadQuit:getWidth() / 2)
	end

  self.tooltip:draw()
end

function Hud:keypressed(key)
  table.with(self.shrujuPatches, 'keypressed', key)
  self.upgrades:keypressed(key)

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
  table.with(self.shrujuPatches, 'keyreleased', key)
	self.upgrades:keyreleased(key)
end

function Hud:gamepadpressed(gamepad, button)
  --
end

function Hud:mousepressed(x, y, b)
  table.with(self.shrujuPatches, 'mousepressed', x, y, b)
end

function Hud:mousereleased(x, y, b)
  local p = ctx.players:get(ctx.id)
  if self.upgrades.active then
    self.units:mousereleased(x, y, b)
  end

	if b == 'l' and ctx.ded then
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

function Hud:resize()
  self.u, self.v = love.graphics.getDimensions()
  self.tooltip:resize()
end
