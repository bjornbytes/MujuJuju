require 'app/enemies/enemy'

Puju = extend(Enemy)

Puju.code = 'puju'
Puju.width = 64
Puju.height = 24
Puju.speed = 40
Puju.damage = 18
Puju.fireRate = 1.1
Puju.maxHealth = 50
Puju.attackRange = Puju.width / 2

Puju.buttRate = 4
Puju.buttDamage = 25
Puju.buttRange = Puju.attackRange * 1.5

function Puju:init(data)
	self.buttTimer = 1
	self.depth = self.depth + love.math.random()
	self.image = love.graphics.newImage('media/skeletons/puju/puju.png')
	self.depth = self.depth + love.math.random()
	self.maxHealth = self.maxHealth + 6 * ctx.enemies.level
	self.damage = self.damage + .5 * ctx.enemies.level
	Enemy.init(self, data)
end

function Puju:update()
	self.buttTimer = timer.rot(self.buttTimer)
	Enemy.update(self)
	self:chooseTarget()
end

function Puju:chooseTarget()
	if not ctx.player.dead then
		self.target = ctx.target:getClosestTarget(self)
	else
		self.target = ctx.target:getClosestNPC(self)
	end

	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale * (1 - self.slow)
	end
end

function Puju:attack()
	self.fireTimer = self.fireRate

	if self.buttTimer == 0 and self.target ~= ctx.player then
		return self:butt()
	end

	if self.target:hurt(self.damage) then self.target = false end
	ctx.sound:play({sound = ctx.sounds.combat})
end

function Puju:butt()
	local targets = ctx.target:getMinionsInRange(self, self.buttRange)
	table.each(targets, function(target)
		if math.sign(self.target.x - self.x) == math.sign(target.x - self.x) then
			target:hurt(self.buttDamage)	
			local sign = math.sign(target.x - self.x)
			target.knockBack = sign * (.1 + love.math.random() / 20)
		end
	end)
	self.buttTimer = self.buttRate
end

function Puju:draw()
	local g = love.graphics
	g.setColor(255, 255, 255)
	local xscale = 1
	local dif = self.target.x - self.x
	if math.sign(dif) > 0 then
		xscale = -xscale
	end

	g.draw(self.image, self.x, self.y + 5 * math.sin(ctx.hud.timer.total * tickRate * 4), 0, xscale, 1, self.image:getWidth() / 2, self.image:getHeight() / 2)
end
