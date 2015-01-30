Shrine = class()
Shrine.code = 'shrine'

Shrine.width = 144
Shrine.height = 144

Shrine.maxHealth = 5000

Shrine.depth = 5

function Shrine:init()
  self.x = ctx.map.width / 2
	self.y = ctx.map.height - ctx.map.groundHeight - self.height - 7
	self.health = self.maxHealth
  self.healthDisplay = self.health
  self.lastHurt = -math.huge
  self.hurtFactor = 0
	self.color = {255, 255, 255}
	self.highlight = 0
  self.regen = 0

  ctx.event:emit('view.register', {object = self})
end

function Shrine:update()
  self.healthDisplay = math.lerp(self.healthDisplay, self.health, math.min(2 * tickRate, 1))

  self.hurtFactor = math.lerp(self.hurtFactor, (tick - self.lastHurt) * tickRate < 5 and 1 or 0, math.min(4 * tickRate, 1))

  if ctx.id then
    local p = ctx.player
    --self.color = table.interpolate(self.color, p.dead and {160, 100, 225} or {255, 255, 255}, math.min(.6 * tickRate, 1))
    self.highlight = math.lerp(self.highlight, p:atShrine() and 100 or 0, math.min(5 * tickRate, 1))
  end

  self.health = math.min(self.health + math.max(self.regen, 0) * tickRate, self.maxHealth)
end

function Shrine:draw()
	local g = love.graphics
  local image = data.media.graphics.shrine

	local scale = self.height / image:getHeight()
	g.setColor(self.color)
	g.draw(image, self.x + 10, self.y + self.height + 16, 0, scale, scale, image:getWidth() / 2, image:getHeight())

	g.setBlendMode('additive')
	g.setColor(255, 255, 255, self.highlight)
	g.draw(image, self.x + 10, self.y + self.height + 16, 0, scale, scale, image:getWidth() / 2, image:getHeight())
	g.setColor(255, 255, 255, 255)
	g.setBlendMode('alpha')
end

function Shrine:getHealthbar()
  return self.x, self.y, self.healthDisplay / self.maxHealth, self.healthDisplay / self.maxHealth
end

function Shrine:hurt(value)
	self.health = math.max(self.health - value, 0)
  self.lastHurt = tick
	if self.health <= 0 and not ctx.ded then
    ctx.event:emit('shrine.dead', {shrine = self})
		return true
	end
end

function Shrine:contains(x, y)
  return math.inside(x, y, self.width - self.width / 2, self.y, self.width, self.height)
end
