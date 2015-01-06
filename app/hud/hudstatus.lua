local g = love.graphics

HudStatus = class()

function HudStatus:init()
	self.jujuScale = 1
  self.populationScale = 1
  self.clockScale = 1
  self.maxPopFactor = 0
  self.jujuAngle = 2 * math.pi

  self.prev = {}
  for _, k in pairs({'jujuScale', 'populationScale', 'clockScale', 'populationr', 'populationg', 'populationb', 'jujuAngle', 'maxPopFactor'}) do
    self.prev[k] = self[k]
  end

  self.clockIcon = data.media.graphics.hud.clockBlue
end

function HudStatus:update()
  for k in pairs(self.prev) do
    self.prev[k] = self[k]
  end

  local p = ctx.players:get(ctx.id)
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
end

function HudStatus:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)

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
  g.draw(image, xx, height / 2, lerpd.jujuAngle, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Juju Text
  g.setFont('mesmerize', height * .4)
  g.setColor(255, 255, 255)
  local str = math.floor(p.juju)
  g.print(str, xx + (v * .03), (height * .5) - g.getFont():getHeight() / 2)
  xx = xx + math.max(v * .06, g.getFont():getWidth(str)) + (v * .04)

  -- Population Icon
  local image = data.media.graphics.hud.population
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.populationScale
  xx = xx + image:getWidth() * scale / 2
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
  g.print(str, xx + (v * .025), (height * .5) - g.getFont():getHeight() / 2)
  xx = xx + math.max(v * .06, g.getFont():getWidth(str)) + (v * .04)
  g.setColor(255, 255, 255)

  -- Timer Icon
  local image = self.clockIcon
  local scale = (height * .6) / image:getHeight()
  local s = scale * lerpd.clockScale
  xx = xx + image:getWidth() * scale / 2
  g.draw(image, xx, height / 2, 0, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Timer Text
  local total = ctx.timer * tickRate
  local seconds = math.floor(total % 60)
  local minutes = math.floor(total / 60)
  if minutes < 10 then minutes = '0' .. minutes end
  if seconds < 10 then seconds = '0' .. seconds end
  local str = minutes .. ':' .. seconds

  g.setColor(255, 255, 255)
  g.print(str, xx + (.025 * v), (height * .5) - g.getFont():getHeight() / 2)
end
