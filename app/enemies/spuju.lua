require 'app/enemies/enemy'

Spuju = extend(Enemy)

Spuju.code = 'spuju'
Spuju.width = 60
Spuju.height = 60
Spuju.maxHealth = 65
Spuju.damage = 6
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
	self.maxHealth = self.maxHealth + 5 * ctx.enemies.level ^ .9
	self.health = self.maxHealth
	self.damage = self.damage + 1.1 * ctx.enemies.level ^ .9
	self.attackRange = self.attackRange + math.min(math.max(ctx.enemies.level - 20, 0) * 2, 100)
	self.clip = 3
	if ctx.enemies.level > 50 then self.clip = self.clip + 1 end
	if ctx.enemies.level > 80 then self.clip = self.clip + 1 end
	self.maxClip = self.clip
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
	if self.damageReduction > 0 then
		g.setColor(255, 255, 255, 200 * math.min(self.damageReductionDuration, 1))
		g.draw(self.curseIcon, self.x, self.y - 65, self.damageReductionDuration * 4, .5, .5, self.curseIcon:getWidth() / 2, self.curseIcon:getHeight() / 2)
	end
end

function Spuju:attack()
	if self.clip == 0 then self.clip = self.maxClip end
	self.clip = self.clip - 1
	self.fireTimer = self.clip == 0 and self.reloadRate or self.fireRate
	local targetx = self.target == ctx.shrine and self.target.x or self.target.x + love.math.randomNormal(65)
	local velocity = 150 + 250 * (math.abs(self.target.x - self.x) / self.attackRange)
	local damage = self.damage * (1 - self.damageReduction)
	ctx.particles:add(SpiritBomb, {x = self.x, y = self.y - self.height / 2, targetx = targetx, velocity = velocity, damage = damage})
end
