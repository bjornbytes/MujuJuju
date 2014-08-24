require 'app/minions/minion'

Voodoo = extend(Minion)

Voodoo.code = 'vuju'
Voodoo.cost = 30 
Voodoo.cooldown = 5
Voodoo.maxHealth = 70
Voodoo.speed = 0

Voodoo.damage = 17
Voodoo.fireRate = 1.7
Voodoo.attackRange = Voodoo.width * 8 

function Voodoo:init(data)
	Minion.init(self, data)

	self.depth = self.depth + love.math.random()
	self.skeleton = Skeleton({name = 'vuju', x = self.x, y = self.y + self.height, scale = .5})

	self.animator = Animator({
		skeleton = self.skeleton,
		mixes = {
			{from = 'idle', to = 'cast', time = .2},
			{from = 'cast', to = 'idle', time = .2},
			{from = 'cast', to = 'death', time = .2},
			{from = 'idle', to = 'death', time = .2}
		}
	})

	self.animationState = 'idle'
	self.animator:add(self.animationState, true)
	self.animator.state.onComplete = function(trackIndex)
		local name = self.animator.state:getCurrent(trackIndex).animation.name
		if name == 'death' then
			ctx.minions:remove(self)
		elseif name == 'cast' then
			self.animationState = 'idle'
			self.animator:add(self.animationState, true)
		end
	end

	self.skeleton.skeleton.flipX = not ctx.player.skeleton.skeleton.flipX

	self.animationSpeeds = table.map({
		idle = .4 * tickRate,
		cast = .8 * tickRate,
		death = .8 * tickRate
	}, f.val)
end

function Voodoo:update()
	if self.animationState == 'death' then
		self.animator:update(self.animationSpeeds[self.animationState]())
		self.healthDisplay = math.lerp(self.healthDisplay, self.health, 20 * tickRate)
		return
	end

	Minion.update(self)
	self.target = ctx.target:getClosestEnemy(self)
	if self.target then
		if self.fireTimer == 0 and self.animationState ~= 'cast' and math.abs(self.target.x - self.x) <= self.attackRange + self.target.width / 2 then
			self.animationState = 'cast'
			self.animator:set(self.animationState, false)
		end
		self:attack()
	end

	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y + self.height + 8
	self.animator:update(self.animationSpeeds[self.animationState]())
end

function Voodoo:draw()
	self.animator:draw()
end

function Voodoo:attack()
	if self.fireTimer == 0 then
		if self.target ~= nil then
			local dif = math.abs(self.target.x - self.x)
			if dif <= self.attackRange + self.target.width / 2 then
				local ct = 1
				if ctx.upgrades.vuju.chain > 0 then
					if love.math.random() < ctx.upgrades.vuju.chain * .2 then
						ct = 2
					end
				end

				for i = 1, ct do
					ctx.particles:add(Lightning, {x = self.target.x})
					if ctx.upgrades.vuju.curse > 0 then
						if love.math.random() < ctx.upgrades.vuju.curse * .2 then
							self.target.slow = 1
						end
					end
					if self.target:hurt(self.damage) then
						self.target = nil
						break
					end
				end

				self.fireTimer = self.fireRate
			end
		end
	end
end

function Voodoo:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
		if self.animationState ~= 'death' then
			self.animationState = 'death'
			self.animator:set('death', false)
		end
		return true
	end
end
