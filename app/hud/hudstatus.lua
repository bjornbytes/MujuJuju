local g = love.graphics

HudStatus = class()

function HudStatus:init()
	self.jujuScale = 1
  self.populationScale = 1
  self.clockScale = 1
  self.jujuAngle = 2 * math.pi

  self.jjpm = 0
  self.jjpmTimer = 1
  self.jjpmHover = false

  self.jujuDisplay = config.player.baseJuju

  self.prev = {}
  for _, k in pairs({'jujuScale', 'populationScale', 'clockScale', 'jujuAngle'}) do
    self.prev[k] = self[k]
  end

  self.clockIcon = data.media.graphics.hud.clockBlue
  self.hitboxes = {juju = {0, 0, 0, 0}, population = {0, 0, 0, 0}, timer = {0, 0, 0, 0}}
end

function HudStatus:update()
  if not ctx.tutorial:shouldShowHudStatus() then return end

  for k in pairs(self.prev) do
    self.prev[k] = self[k]
  end

  local p = ctx.player
	self.jujuScale = math.lerp(self.jujuScale, 1, 10 * ls.tickrate)
  self.populationScale = math.lerp(self.populationScale, 1, 10 * ls.tickrate)
  self.clockScale = math.lerp(self.clockScale, 1, 10 * ls.tickrate)
  self.jujuAngle = math.lerp(self.jujuAngle, 2 * math.pi, math.min(3 * ls.tickrate, 1))

  local benchmark = 'Blue'
  local old = self.clockIcon
  if math.floor(ctx.timer * ls.tickrate) >= config.medals.gold then benchmark = 'Gold'
  elseif math.floor(ctx.timer * ls.tickrate) >= config.medals.silver then benchmark = 'Silver'
  elseif math.floor(ctx.timer * ls.tickrate) >= config.medals.bronze then benchmark = 'Bronze' end
  self.clockIcon = data.media.graphics.hud['clock' .. benchmark]
  if self.clockIcon ~= old then
    self.clockScale = 2
  end

  self.jjpmTimer = timer.rot(self.jjpmTimer, function()
    self.jjpm = math.round((p.totalJuju / (ctx.timer * ls.tickrate / 60)) / .1) * .1
    if self.jjpmHover then ctx:mousemoved(love.mouse.getPosition()) end
    return .5
  end)

  self.jujuDisplay = math.lerp(self.jujuDisplay, p.juju, 10 * ls.tickrate)
  if math.abs(self.jujuDisplay - p.juju) < 1 then self.jujuDisplay = p.juju end
end

function HudStatus:draw()
  if not ctx.tutorial:shouldShowHudStatus() then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.player
  local mx, my = love.mouse.getPosition()

  local lerpd = {}
  for k in pairs(self.prev) do
    lerpd[k] = math.lerp(self.prev[k], self[k], ls.accum / ls.tickrate)
  end

  -- Status bar
  local image = data.media.graphics.hud.statusBar
  local scale = v * .07 / image:getHeight()
  local width, height = 425 * scale, 60 * scale
  g.setColor(255, 255, 255)
  g.draw(image, u + .05 * u, 0, 0, scale, scale, image:getWidth(), 0)

  -- Juju Icon
  local image = data.media.graphics.juju
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.jujuScale
  local xx = u - width + (v * .035) + image:getWidth() / 2 * scale + .05 * u
  local hitboxX = xx - image:getWidth() / 2 * scale
  g.draw(image, xx, height / 2, lerpd.jujuAngle, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Juju Text
  g.setFont('mesmerize', height * .4)
  g.setColor(255, 255, 255)
  local str = math.floor(self.jujuDisplay)
  g.print(str, xx + (v * .03), (height * .5) - g.getFont():getHeight() / 2 + 1)
  local hitboxWidth = (xx + (v * .03) + g.getFont():getWidth(str)) - hitboxX
  self.hitboxes.juju[1] = hitboxX
  self.hitboxes.juju[2] = 0
  self.hitboxes.juju[3] = hitboxWidth
  self.hitboxes.juju[4] = height

  xx = xx + math.max(v * .06, g.getFont():getWidth(str)) + (v * .07)
  local hitboxX = xx

  -- Population Icon
  --[[local image = data.media.graphics.hud.population
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.populationScale
  xx = xx + image:getWidth() / 2 * scale
  local r, gg, b = 21, 142, 149
  g.setColor(r, gg, b)
  g.draw(image, xx, height / 2, 0, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Population Text
  local str = 0
  local r, gg, b = 255, 255, 255
  g.setColor(r, gg, b)
  g.print(str, xx + (v * .025), (height * .5) - g.getFont():getHeight() / 2 + 1)
  local hitboxWidth = (xx + (v * .025) + g.getFont():getWidth(str)) - hitboxX
  self.hitboxes.population[1] = hitboxX
  self.hitboxes.population[2] = 0
  self.hitboxes.population[3] = hitboxWidth
  self.hitboxes.population[4] = height

  xx = xx + math.max(v * .05, g.getFont():getWidth(str)) + (v * .04)
  local hitboxX = xx
  g.setColor(255, 255, 255)]]

  -- Timer Icon
  local image = self.clockIcon
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.clockScale
  xx = xx + image:getWidth() / 2 * scale
  g.draw(image, xx, height / 2, 0, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Timer Text
  local str = toTime(ctx.timer * ls.tickrate, true)

  g.setColor(255, 255, 255)
  g.print(str, xx + (.025 * v), (height * .5) - g.getFont():getHeight() / 2 + 1)
  local hitboxWidth = (xx + (v * .025) + g.getFont():getWidth(str)) - hitboxX
  self.hitboxes.timer[1] = hitboxX
  self.hitboxes.timer[2] = 0
  self.hitboxes.timer[3] = hitboxWidth
  self.hitboxes.timer[4] = height
end

function HudStatus:mousemoved(mx, my)
  if not ctx.tutorial:shouldShowHudStatus() then return end

  local p = ctx.player
  self.jjpmHover = false
  if math.inside(mx, my, unpack(self.hitboxes.juju)) then
    self.jjpmHover = true
    ctx.hud.tooltip:setTooltip('{white}{title}Juju{normal}\n{whoCares}Use it to summon minions and purchase upgrades.  Collect it in the juju realm.\n\n{green}' .. p.totalJuju .. ' {white}total juju ({green}' .. self.jjpm .. ' {white}per minute)')
  elseif math.inside(mx, my, unpack(self.hitboxes.population)) then
    --ooltip('{white}{title}Population{normal}\n{whoCares}The maximum number of minions you may summon at once.\n\n{green}' .. p.totalSummoned .. ' {white}minion' .. (p.totalSummoned == 1 and '' or 's') .. ' summoned.')
  elseif math.inside(mx, my, unpack(self.hitboxes.timer)) then
    local str = ''
    local time = ctx.timer * ls.tickrate
    str = str .. 'Bronze: ' .. (time >= config.medals.bronze and '{green}' or '{red}') .. toTime(config.medals.bronze) .. '{white}\n'
    str = str .. 'Silver: ' .. (time >= config.medals.silver and '{green}' or '{red}') .. toTime(config.medals.silver) .. '{white}\n'
    str = str .. 'Gold: ' .. (time >= config.medals.gold and '{green}' or '{red}') .. toTime(config.medals.gold) .. '{white}\n'
    ctx.hud.tooltip:setTooltip('{white}{title}Timer{normal}\n{whoCares}How long you\'ve lasted.  Survive for a long time to unlock rewards!\n\n' .. str)
  end
end
