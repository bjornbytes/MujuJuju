require 'app/enemies/enemy'

Puju = extend(Enemy)

Puju.code = 'puju'
Puju.width = 64
Puju.height = 24
Puju.speed = 40
Puju.damage = 18
Puju.fireRate = 1.1
Puju.maxHealth = 40
Puju.attackRange = Puju.width / 2

Puju.buttRate = 4
Puju.buttDamage = 25
Puju.buttRange = Puju.attackRange * 1.5

Puju.image = love.graphics.newImage('media/skeletons/puju/puju.png')

function Puju:init(data)
	self.buttTimer = 1
	Enemy.init(self, data)
	local r = love.math.random(-20, 20)
	self.scale = 1 + (r / 210)
	self.y = self.y + r
	self.depth = self.depth - r / 20 + love.math.random() * (1 / 20)
	self.maxHealth = self.maxHealth + 4 * ctx.enemies.level ^ 1.185
	self.health = self.maxHealth
	self.damage = self.damage + .3 * ctx.enemies.level ^ 1.2
end

function Puju:update()
	Enemy.update(self)

	self.target = ctx.player.dead and ctx.target:getClosestNPC(self) or ctx.target:getClosestTarget(self)
	self:move()

	self.buttTimer = timer.rot(self.buttTimer)
end

function Puju:attack()
	self.fireTimer = self.fireRate

	if self.buttTimer == 0 and self.target ~= ctx.player and love.math.random() < .6 then
		return self:butt()
	end

	if self.target:hurt(self.damage) then self.target = false end
	if self.target == ctx.shrine and ctx.upgrades.muju.imbue >= 3 then
		self:hurt(self.damage / 2)
	end
	ctx.sound:play({sound = ctx.sounds.combat})
end

function Puju:butt()
	local targets = ctx.target:getMinionsInRange(self, self.buttRange * 2)
	table.each(targets, function(target)
		if math.sign(self.target.x - self.x) == math.sign(target.x - self.x) then
			target:hurt(self.buttDamage)
			local sign = math.sign(target.x - self.x)
			target.knockBack = sign * (.1 + love.math.random() / 15)
		end
	end)
	self.buttTimer = self.buttRate
end

function Puju:draw()
	local g = love.graphics
	local sign = -math.sign(self.target.x - self.x)
	g.setColor(255, 255, 255)
	g.draw(self.image, self.x, self.y + 5 * math.sin(ctx.hud.timer.total * tickRate * 4), 0, self.scale * sign, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end
