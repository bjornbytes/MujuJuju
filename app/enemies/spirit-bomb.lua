require 'app/enemies/enemy'

SpiritBomb = extend(Enemy)

SpiritBomb.code = 'spirit-bomb'
SpiritBomb.width = 35
SpiritBomb.height = 35
SpiritBomb.maxHealth = 200
SpiritBomb.damage = 100
SpiritBomb.attackRange = 100
SpiritBomb.speed = 7

function SpiritBomb:init(data)
	self.depth = self.depth + love.math.random()
	self.image = love.graphics.newImage('media/skeletons/spirit-bomb/spuju.png')
	Enemy.init(self, data)
end

function SpiritBomb:update()
	self.timeScale = 1
	local dif = self.target.x - self.x
	self.target = ctx.target:getShrine(self)
	if math.abs(dif) > 20 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale * (1 - self.slow)
	else
		self:attack()
	end

	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
	self.slow = math.lerp(self.slow, 0, 1 * tickRate)
end

function SpiritBomb:draw()
	local g = love.graphics
	g.setColor(255, 255, 255)
	local scalex = .8 
	local dif = self.target.x - self.x
	if math.sign(dif) > 0 then
		scalex = -scalex
	end
	g.draw(self.image, self.x, self.y + 5 * math.sin(tick * tickRate * 4), 0, scalex, .8, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

function SpiritBomb:attack()
	local dif
	ctx.particles:add(Burst, {x = self.x, y = self.y, radius = self.attackRange})

	table.each(ctx.minions.minions, function(minion)
		dif = minion.x - self.x
		if math.abs(dif) <= self.attackRange + minion.width / 2 then
			minion:hurt(self.damage)		
		end
	end)

	dif = ctx.player.x - self.x
	if math.abs(dif) <= self.attackRange + ctx.player.width / 2 and not ctx.player.dead then
		ctx.player:hurt(self.damage)
	end

	self.target:hurt(self.damage)
	self:hurt(self.health)
end
