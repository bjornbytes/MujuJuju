local SpujuSkull = extend(Spell)
SpujuSkull.code = 'spujuskull'

SpujuSkull.gravity = 700
SpujuSkull.scale = 1
SpujuSkull.maxHealth = .3
SpujuSkull.radius = 40

function SpujuSkull:activate()
  self.x = self.unit.x
  self.y = self.unit.y - self.unit.height / 2
  local targetx = self.target.x
	local dx = math.abs(targetx - self.x)
	local dy = -self.unit.height
	local g = self.gravity
	local v = 150 + 250 * (dx / self.unit.range) -- velocity
	local root = math.sqrt(v ^ 4 - (g * ((g * dx ^ 2) + (2 * dy * v ^ 2))))
	local angle
	if root ~= root then
		angle = math.pi / 2 + love.math.random(-math.pi / 4, math.pi / 4)
	else
		local a1, a2 = math.atan((v ^ 2 + root) / (g * dx)), math.atan((v ^ 2 - root) / (g * dx))
		angle = math.max(a1, a2)
	end
	self.vx = math.cos(angle) * math.max(v - 10, 0) * math.sign(targetx - self.x)
	self.vy = math.sin(angle) * -v
	self.angle = love.math.random() * 2 * math.pi
  self.team = self.unit.team
	self.health = nil
	self.burstScale = 0
  ctx.event:emit('view.register', {object = self})
end

function SpujuSkull:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function SpujuSkull:update()
  local image = data.media.graphics.spujuSkull
	if self.health then
		self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
		self.burstScale = math.lerp(self.burstScale, self.radius / data.media.graphics.spell.burst:getWidth(), 20 * tickRate)
	else
		self.x = self.x + self.vx * tickRate
		self.y = self.y + self.vy * tickRate
		self.vy = self.vy + self.gravity * tickRate
		self.angle = self.angle + math.sign(self.vx) * tickRate
		if self.y + image:getWidth() >= love.graphics.getHeight() - ctx.map.groundHeight then
			self.health = self.maxHealth
      local targets = ctx.target:inRange(self, self.radius, 'enemy', 'unit', 'player', 'shrine')
      table.each(targets, function(target)
        self.unit:attack(target, {nosound = true})
      end)
      if next(targets) then
        ctx.sound:play(data.media.sounds.spuju.attackHit, function(sound)
          sound:setVolume(.4)
        end)
      end
		end
	end
end

function SpujuSkull:draw()
	local g = love.graphics
	if self.health then
		g.setColor(80, 230, 80, 200 * self.health / self.maxHealth)
    local image = data.media.graphics.spell.burst
		g.draw(image, self.x, g.getHeight() - ctx.map.groundHeight, self.angle, self.burstScale + .25, self.burstScale + .25, image:getWidth() / 2, image:getHeight() / 2)
	else
		g.setColor(255, 255, 255)
    local image = data.media.graphics.spujuSkull
		g.draw(image, self.x, self.y, self.angle, self.scale, self.scale, image:getWidth() / 2, image:getHeight() / 2)
	end
end

return SpujuSkull
