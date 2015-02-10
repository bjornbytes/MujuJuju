local g = love.graphics

HudStatus = class()

function HudStatus:init()
	self.jujuScale = 1
  self.populationScale = 1
  self.clockScale = 1
  self.maxPopFactor = 0
  self.jujuAngle = 2 * math.pi

  self.jjpm = 0
  self.jjpmTimer = 1

  self.jujuDisplay = config.player.baseJuju

  self.prev = {}
  for _, k in pairs({'jujuScale', 'populationScale', 'clockScale', 'populationr', 'populationg', 'populationb', 'jujuAngle', 'maxPopFactor'}) do
    self.prev[k] = self[k]
  end

  self.clockIcon = data.media.graphics.hud.clockBlue
  self.hitboxes = {juju = {0, 0, 0, 0}, population = {0, 0, 0, 0}, timer = {0, 0, 0, 0}}
end

function HudStatus:update()
  for k in pairs(self.prev) do
    self.prev[k] = self[k]
  end

  local p = ctx.player
  local maxPop = p:getPopulation() >= p.maxPopulation
	self.jujuScale = math.lerp(self.jujuScale, 1, 10 * tickRate)
  self.populationScale = math.lerp(self.populationScale, 1, 10 * tickRate)
  self.clockScale = math.lerp(self.clockScale, 1, 10 * tickRate)
  self.maxPopFactor = math.lerp(self.maxPopFactor, maxPop and 1 or 0, 10 * tickRate)
  self.jujuAngle = math.lerp(self.jujuAngle, 2 * math.pi, math.min(3 * tickRate, 1))

  local benchmark = 'Blue'
  local old = self.clockIcon
  if math.floor(ctx.timer * tickRate) >= config.biomes[ctx.biome].benchmarks.gold then benchmark = 'Gold'
  elseif math.floor(ctx.timer * tickRate) >= config.biomes[ctx.biome].benchmarks.silver then benchmark = 'Silver'
  elseif math.floor(ctx.timer * tickRate) >= config.biomes[ctx.biome].benchmarks.bronze then benchmark = 'Bronze' end
  self.clockIcon = data.media.graphics.hud['clock' .. benchmark]
  if self.clockIcon ~= old then
    self.clockScale = 2
  end

  self.jjpmTimer = timer.rot(self.jjpmTimer, function()
    self.jjpm = math.round((p.totalJuju / (ctx.timer * tickRate / 60)) / .1) * .1
    return .5
  end)

  local mx, my = love.mouse.getPosition()
  if math.inside(mx, my, unpack(self.hitboxes.juju)) then
    ctx.hud.tooltip:setTooltip('{white}{title}Juju{normal}\n{whoCares}Use it to summon minions and purchase upgrades.  Collect it in the juju realm.\n\n{green}' .. p.totalJuju .. ' {white}total juju ({green}' .. self.jjpm .. ' {white}per minute)')
  elseif math.inside(mx, my, unpack(self.hitboxes.population)) then
    ctx.hud.tooltip:setTooltip('{white}{title}Population{normal}\n{whoCares}The maximum number of minions you may summon at once.\n\n{green}' .. p.totalSummoned .. ' {white}minion' .. (p.totalSummoned == 1 and '' or 's') .. ' summoned.')
  elseif math.inside(mx, my, unpack(self.hitboxes.timer)) then
    local str = ''
    local benchmarks = config.biomes[ctx.biome].benchmarks
    local time = ctx.timer * tickRate
    str = str .. 'Bronze: ' .. (time >= benchmarks.bronze and '{green}' or '{red}') .. toTime(benchmarks.bronze) .. '{white}\n'
    str = str .. 'Silver: ' .. (time >= benchmarks.silver and '{green}' or '{red}') .. toTime(benchmarks.silver) .. '{white}\n'
    str = str .. 'Gold: ' .. (time >= benchmarks.gold and '{green}' or '{red}') .. toTime(benchmarks.gold) .. '{white}\n'
    ctx.hud.tooltip:setTooltip('{white}{title}Timer{normal}\n{whoCares}How long you\'ve lasted.  Survive for a long time to unlock rewards!\n\n' .. str)
  end

  self.jujuDisplay = math.lerp(self.jujuDisplay, p.juju, 10 * tickRate)
  if math.abs(self.jujuDisplay - p.juju) < 1 then self.jujuDisplay = p.juju end
end

function HudStatus:draw()
  if ctx.tutorial then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.player
  local mx, my = love.mouse.getPosition()

  local lerpd = {}
  for k in pairs(self.prev) do
    lerpd[k] = math.lerp(self.prev[k], self[k], tickDelta / tickRate)
  end

  -- Status bar
  local image = data.media.graphics.hud.statusBar
  local scale = v * .07 / image:getHeight()
  local width, height = 425 * scale, 60 * scale
  g.setColor(255, 255, 255)
  g.draw(image, u, 0, 0, scale, scale, image:getWidth(), 0)

  -- Juju Icon
  local image = data.media.graphics.juju
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.jujuScale
  local xx = u - width + (v * .035) + image:getWidth() / 2 * scale
  local hitboxX = xx - image:getWidth() / 2 * scale
  g.draw(image, xx, height / 2, lerpd.jujuAngle, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Juju Text
  g.setFont('mesmerize', height * .4)
  g.setColor(255, 255, 255)
  local str = p.level .. ', ' .. p.skillPoints .. ', ' .. p.attributePoints
  g.print(str, xx + (v * .03), (height * .5) - g.getFont():getHeight() / 2 + 1)
  local hitboxWidth = (xx + (v * .03) + g.getFont():getWidth(str)) - hitboxX
  self.hitboxes.juju[1] = hitboxX
  self.hitboxes.juju[2] = 0
  self.hitboxes.juju[3] = hitboxWidth
  self.hitboxes.juju[4] = height

  xx = xx + math.max(v * .06, g.getFont():getWidth(str)) + (v * .05)
  local hitboxX = xx

  -- Population Icon
  local image = data.media.graphics.hud.population
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.populationScale
  xx = xx + image:getWidth() / 2 * scale
  local r = math.lerp(21, 255, lerpd.maxPopFactor)
  local gg = math.lerp(142, 100, lerpd.maxPopFactor)
  local b = math.lerp(149, 100, lerpd.maxPopFactor)
  g.setColor(r, gg, b)
  g.draw(image, xx, height / 2, 0, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Population Text
  local str = p:getPopulation() .. ' / ' .. p.maxPopulation
  local r = math.lerp(255, 255, lerpd.maxPopFactor)
  local gg = math.lerp(255, 150, lerpd.maxPopFactor)
  local b = math.lerp(255, 150, lerpd.maxPopFactor)
  g.setColor(r, gg, b)
  g.print(str, xx + (v * .025), (height * .5) - g.getFont():getHeight() / 2 + 1)
  local hitboxWidth = (xx + (v * .025) + g.getFont():getWidth(str)) - hitboxX
  self.hitboxes.population[1] = hitboxX
  self.hitboxes.population[2] = 0
  self.hitboxes.population[3] = hitboxWidth
  self.hitboxes.population[4] = height

  xx = xx + math.max(v * .05, g.getFont():getWidth(str)) + (v * .04)
  local hitboxX = xx
  g.setColor(255, 255, 255)

  -- Timer Icon
  local image = self.clockIcon
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.clockScale
  xx = xx + image:getWidth() / 2 * scale
  g.draw(image, xx, height / 2, 0, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Timer Text
  local str = toTime(ctx.timer * tickRate, true)

  g.setColor(255, 255, 255)
  g.print(str, xx + (.025 * v), (height * .5) - g.getFont():getHeight() / 2 + 1)
  local hitboxWidth = (xx + (v * .025) + g.getFont():getWidth(str)) - hitboxX
  self.hitboxes.timer[1] = hitboxX
  self.hitboxes.timer[2] = 0
  self.hitboxes.timer[3] = hitboxWidth
  self.hitboxes.timer[4] = height

  -- Enemy spawn debug text
  --[[g.setFont('pixel', 8)
  g.setColor(255, 255, 255)
  local str = math.round(ctx.units.level / .1) * .1 .. '\n' .. math.round(ctx.units.minEnemyRate / .1) * .1 .. ' - ' .. math.round(ctx.units.maxEnemyRate / .1) * .1 .. '\n' .. 1 + math.floor(ctx.units.level * config.biomes[ctx.biome].units.maxEnemiesCoefficient)
  g.print(str, u - g.getFont():getWidth(str) - 4, height + 4)]]

  -- Experience debug text
  --[[g.setFont('pixel', 8)
  g.setColor(255, 255, 255)
  local str = 'Level ' .. p.level .. '\n' .. math.floor(p.experience) .. ' / ' .. p.nextLevels[p.level] .. '\n' .. p.skillPoints .. ' skill points'
  g.print(str, u - g.getFont():getWidth(str) - 4, height + 4)]]
end
