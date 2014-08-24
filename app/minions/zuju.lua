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
	self.depth = self.depth + love.math.random()
	self.skeleton = Skeleton({name = 'zuju', x = self.x, y = self.y + self.height, scale = .5})

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
		if name == 'spawn' then
			self.animationLock = nil
			self.animationState = 'idle'
			self.animator:set(self.animationState, true)
		elseif name == 'death' then
			ctx.minions:remove(self)
		end
	end

	self.skeleton.skeleton.flipX = not ctx.player.skeleton.skeleton.flipX

	self.animationSpeeds = table.map({
		walk = .73 * tickRate,
		idle = .3 * tickRate,
		cast = .85 * tickRate,
		spawn = .85 * tickRate,
		death = .8 * tickRate
	}, f.val)
end

function Zuju:update()
	if self.animationState == 'death' or self.animationState == 'spawn' then
		self.animator:update(self.animationSpeeds[self.animationState]())
		return
	end

	Minion.update(self)

	if self.target == nil then
		self.target = ctx.target:getShrine(self)
	end
	local dif = self.target.x - self.x
	local inRange = math.abs(dif) <= self.attackRange + self.target.width / 2
	if not inRange then
		self.x = self.x + self.speed * math.sign(dif) * tickRate * self.timeScale
	end

	if not self.animationLock then
		if not inRange and self.animationState ~= 'walk' then
			self.animationState = 'walk'
			self.animator:set(self.animationState, true)
		elseif inRange and self.target == ctx.shrine and self.animationState ~= 'idle' then
			self.animationState = 'idle'
			self.animator:set(self.animationState, true)
		end
	end

	if self.animationState == 'walk' then
		self.skeleton.skeleton.flipX = dif < 0
	end

	self.skeleton.skeleton.x = self.x
	self.skeleton.skeleton.y = self.y + self.height + 8
	self.animator:update(self.animationSpeeds[self.animationState]())
end

function Zuju:draw()
	self.animator:draw()
end

function Zuju:hurt(amount)
	self.health = math.max(self.health - amount, 0)
	if self.health <= 0 then
		if self.animationState ~= 'death' then
			self.animationLock = true
			self.animationState = 'death'
			self.animator:set('death', false)
		end
		return true
	end
end