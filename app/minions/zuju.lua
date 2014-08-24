require('app/minions/minion')

Zuju = extend(Minion)

Zuju.code = 'zuju'
Zuju.cost = 10
Zuju.cooldown = 2.5

Zuju.speed = 45
Zuju.damage = 20
Zuju.fireRate = 1
Zuju.attackRange = Zuju.width / 2
Zuju.maxHealth = 80

function Zuju:init(data)
	Minion.init(self, data)
	self.skeleton = Skeleton({name = 'zuju', x = self.x, y = self.y, scale = .5})

	self.animator = Animator({
		skeleton = self.skeleton,
		mixes = {
			{from = 'spawn', to = 'walk', time = .2},
			{from = 'walk', to = 'cast', time = .2},
			{from = 'cast', to = 'walk', time = .2},
			{from = 'cast', to = 'death', time = .2},
			{from = 'walk', to = 'death', time = .2}
		}
	})

	self.animationState = 'spawn'
	self.animationLock = true
	self.animator:add(self.animationState, false)
	self.animator.state.onComplete = function(trackIndex)
		local name = self.animator.state:getCurrent(trackIndex).animation.name
		if name == 'spawn' or name == 'cast' then
			self.animationLock = nil
		elseif name == 'death' then
			ctx.minions:remove(self)
		end
	end

	self.animationSpeeds = table.map({
		walk = .73 * tickRate,
		idle = .3 * tickRate,
		cast = .85 * tickRate,
		spawn = .45 * tickRate,
		death = .8 * tickRate
	}, f.val)
end

function Zuju:update()
	if self.animationState == 'death' then return end
	Minion.update(self)
	if self.target == nil then
		self.target = ctx.target:getShrine(self)
	end
	local dif = self.target.x - self.x
	if math.abs(dif) > self.attackRange + self.target.width / 2 then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	elseif self.fireTimer == 0 and self.animationLock == nil then
		self.animationState = 'cast'
		self.animationLock = true
		self.animator:set(self.animationState, false)
	end

	if not self.animationLock then
		if math.abs(dif) > self.attackRange + self.target.width / 2 and self.animationState ~= 'walk' then
			self.animationState = 'walk'
			self.animator:set(self.animationState, true)
			self.skeleton.skeleton.flipX = dif < 0
		elseif self.target == ctx.shrine and self.animationState ~= 'idle' then
			self.animationState = 'idle'
			self.animator:set(self.animationState, true)
		end
	end

	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y + self.height / 2
	self.animator:update(self.animationSpeeds[self.animationState]())
end

function Zuju:draw()
	self.animator:draw()
end

function Zuju:hurt(amount)
	self.health = self.health - amount
	if self.health <= 0 then
		self.animationLock = true
		self.animationState = 'death'
		self.animator:set('death', false)
		return true
	end
end
