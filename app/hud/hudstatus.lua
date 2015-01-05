local g = love.graphics

HudStatus = class()

function HudStatus:init()
	self.jujuIconScale = 1
  self.jujuAngle = 2 * math.pi
  self.prevJujuAngle = self.jujuAngle
	self.timer = {total = 0, minutes = 0, seconds = 0}
end

function HudStatus:update()
	self.jujuIconScale = math.lerp(self.jujuIconScale, 1, 12 * tickRate)
  self.prevJujuAngle = self.jujuAngle
  self.jujuAngle = math.lerp(self.jujuAngle, 2 * math.pi, math.min(3 * tickRate, 1))
end

function HudStatus:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.players:get(ctx.id)

  -- Status bar
  local angle = math.anglerp(self.prevJujuAngle, self.jujuAngle, tickDelta / tickRate)
  local image = data.media.graphics.hud.statusBar
  local scale = v * .07 / image:getHeight()
  local width, height = 425 * scale, 60 * scale
  g.draw(image, u, 0, 0, scale, scale, image:getWidth(), 0)

  -- Juju Icon
  local image = data.media.graphics.juju
  local scale = (height * .6) / image:getHeight()
  local s = scale * self.jujuIconScale
  local xx = u - width + (v * .035) + image:getWidth() / 2 * scale
  g.draw(image, xx, height / 2, angle, s, s, image:getWidth() / 2, image:getHeight() / 2)

  -- Juju Text
  g.setFont('mesmerize', height * .4)
  g.setColor(255, 255, 255)
  local str = math.floor(p.juju)
  g.print(str, xx + (v * .03), (height * .5) - g.getFont():getHeight() / 2)
  xx = xx + math.max(v * .06, g.getFont():getWidth(str)) + (v * .04)

  -- Population Icon
  local image = data.media.graphics.hud.population
  local scale = (height * .6) / image:getHeight()
  xx = xx + image:getWidth() * scale / 2
  g.draw(image, xx, height / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

  -- Population Text
  local str = p:getPopulation() .. ' / ' .. p.maxPopulation
  g.print(str, xx + (v * .025), (height * .5) - g.getFont():getHeight() / 2)
  xx = xx + math.max(v * .06, g.getFont():getWidth(str)) + (v * .04)

  -- Timer Icon
  local image = data.media.graphics.hud.clockBlue
  local scale = (height * .6) / image:getHeight()
  xx = xx + image:getWidth() * scale / 2
  g.draw(image, xx, height / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

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
