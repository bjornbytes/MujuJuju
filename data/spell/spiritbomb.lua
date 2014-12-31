local SpiritBomb = class()
SpiritBomb.code = 'spiritbomb'

SpiritBomb.gravity = 700
SpiritBomb.scale = 1
SpiritBomb.radius = 40

function SpiritBomb:activate()
	local dx = math.abs(self.targetx - self.x)
	local dy = -data.unit.spuju.height
	local g = self.gravity
	local v = self.velocity
	local root = math.sqrt(v ^ 4 - (g * ((g * dx ^ 2) + (2 * dy * v ^ 2))))
	local angle
	if root ~= root then
		angle = math.pi / 2 + love.math.random(-math.pi / 4, math.pi / 4)
	else
		local a1, a2 = math.atan((v ^ 2 + root) / (g * dx)), math.atan((v ^ 2 - root) / (g * dx))
		angle = math.max(a1, a2)
	end
	self.vx = math.cos(angle) * v * math.sign(self.targetx - self.x)
	self.vy = math.sin(angle) * -v
	self.angle = love.math.random() * 2 * math.pi
  ctx.event:emit('view.register', {object = self})
end

function SpiritBomb:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function SpiritBomb:update()
  self.x = self.x + self.vx * tickRate
  self.y = self.y + self.vy * tickRate
  self.vy = self.vy + self.gravity * tickRate
  self.angle = self.angle + math.sign(self.vx) * tickRate
  if self.y + 27 >= ctx.map.height - ctx.map.groundHeight then
    table.each(ctx.target:inRange(self, self.radius, 'enemy', 'unit', 'shrine', 'player'), function(obj)
      obj:hurt(self.damage, self.owner)
    end)
    ctx.event:emit('particles.add', {kind = 'spiritbomb', x = self.x, y = self.y, radius = self.radius})
    ctx.spells:remove(self)
  end
end

function SpiritBomb:draw()
	local g = love.graphics
  local image = data.media.graphics.spujuSkull
  g.setColor(255, 255, 255)
  g.draw(image, self.x, self.y, self.angle, self.scale, self.scale, image:getWidth() / 2, image:getHeight() / 2)
end

return SpiritBomb
