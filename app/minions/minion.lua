Minion = class()

Minion.width = 48
Minion.height = 48

Minion.depth = -10

function Minion:init(data)
	self.knockBack = 0
	self.knockBackDisplay = 0
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)

	self.health = self.maxHealth
	self.healthDisplay = self.health

	ctx.view:register(self)
end

function Minion:update()
	self.timeScale = 1 / (1 + ctx.upgrades.muju.distort.level * (ctx.player.dead and 1 or 0))
	self.target = ctx.target:getClosestEnemy(self)
	if self.target ~= ctx.shrine then
		self:attack()
	end
	
	self.fireTimer = self.fireTimer - math.min(self.fireTimer, tickRate * self.timeScale)
	self:hurt(self.maxHealth * .02 * tickRate)
	self.speed = math.max(self.speed - .5 * tickRate, 20)
	self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)

	self.x = self.x + self.knockBack * tickRate * 3000
	self.knockBack = math.max(0, math.abs(self.knockBack) - tickRate) * math.sign(self.knockBack)
	self.knockBackDisplay = math.lerp(self.knockBackDisplay, math.abs(self.knockBack), 20 * tickRate)
end

function Minion:attack()
	if self.fireTimer == 0 then		
		if self.target ~= nil then
			local dif = math.abs(self.target.x - self.x)
			if dif <= self.attackRange + self.target.width / 2 then
				local damage = type(self.damage) == 'function' and self:damage() or self.damage
				if self.code == 'zuju' then
					self.health = math.min(self.health + (.1 * damage * ctx.upgrades.zuju.siphon.level), self.maxHealth)
				end

				self.target:hurt(damage)
				self.fireTimer = self.fireRate
				local pitch = 1 + love.math.random() * .2
				if love.math.random() > .5 then
					pitch = 1 / pitch
				end
				if not ctx.sound.muted then
					ctx.sound:play({sound = ctx.sounds.combat}):setPitch(pitch)
				end
			end
		end
	end
end

function Minion:hurt(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		ctx.minions:remove(self)
		return true
	end
end

function Minion:draw()
	local g = love.graphics

	g.setColor(0, 255, 0, 160)
	g.rectangle('fill', self.x - self.width / 2, self.y, self.width, self.height)

	g.setColor(0, 255, 0)
	g.rectangle('line', self.x - self.width / 2, self.y, self.width, self.height)
end
