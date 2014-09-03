require 'app/enemies/enemy'

Spuju = extend(Enemy)

Spuju.code = 'spuju'
Spuju.width = 60
Spuju.height = 60
Spuju.maxHealth = 65
Spuju.damage = 5
Spuju.fireRate = .3
Spuju.reloadRate = 2.1
Spuju.attackRange = Spuju.width * 2
Spuju.speed = 18
Spuju.image = love.graphics.newImage('media/skeletons/spuju/spuju.png')

function Spuju:init(data)
	Enemy.init(self, data)

	local r = love.math.random(-25, 25)
	self.y = self.y + r
	self.scale = .8 + (r / 210)
	self.depth = self.depth - r / 25 + love.math.random() * (1 / 25)
	self.maxHealth = self.maxHealth + 4 * ctx.enemies.level ^ 1
	self.health = self.maxHealth
	self.damage = self.damage + .45 * ctx.enemies.level ^ 1.4
	self.clip = 3
end

function Spuju:update()
	Enemy.update(self)

	self.target = ctx.target:getClosestNPC(self)
	self:move()
end

function Spuju:draw()
	local g = love.graphics
	local sign = -math.sign(self.target.x - self.x)
	g.setColor(255, 255, 255)
	g.draw(self.image, self.x, self.y + 2 * math.sin(tick * tickRate * 4 + math.pi / 2), 0, self.scale * sign, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

function Spuju:attack()
	if self.clip == 0 then self.clip = 3 end
	self.clip = self.clip - 1
	self.fireTimer = self.clip == 0 and self.reloadRate or self.fireRate
	local targetx = self.target == ctx.shrine and self.target.x or self.target.x + love.math.randomNormal(65)
	local velocity = 150 + 250 * (math.abs(self.target.x - self.x) / self.attackRange)
	ctx.particles:add(SpiritBomb, {x = self.x, y = self.y - self.height / 2, targetx = targetx, velocity = velocity, damage = self.damage})
	ctx.sound:play({sound = ctx.sounds.combat})
end
