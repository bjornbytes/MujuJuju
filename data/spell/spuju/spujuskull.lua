local SpujuSkull = extend(Spell)

SpujuSkull.gravity = 700
SpujuSkull.scale = 1
SpujuSkull.maxHealth = .3
SpujuSkull.radius = 25

function SpujuSkull:activate()
  self.x = self.unit.x
  self.y = self.unit.y - self.unit.height / 2
  local targetx = self.target.x
	local dx = math.abs(targetx + love.math.randomNormal(30) - self.x)
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
  local image = data.media.graphics.spell.spujuSkull
	if self.health then
		self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
		self.burstScale = math.lerp(self.burstScale, 2 * self.radius / data.media.graphics.spell.burst:getWidth(), 20 * ls.tickrate)
	else
		self.x = self.x + self.vx * ls.tickrate
		self.y = self.y + self.vy * ls.tickrate
		self.vy = self.vy + self.gravity * ls.tickrate
		self.angle = self.angle + math.sign(self.vx) * ls.tickrate

    if love.math.random() < 30 * ls.tickrate then
      ctx.particles:emit('spujuskulltrail', self.x, self.y, 1)
    end

		if self.y + image:getWidth() >= ctx.map.height - ctx.map.groundHeight then
			self.health = self.maxHealth
      local targets = ctx.target:inRange(self, self.radius, 'enemy', 'player', 'unit', 'shrine')
      local damage = self.unit.damage
      if #targets >= 2 then damage = damage / 2 end
      table.each(targets, function(target)
        self.unit:attack({target = target, damage = damage, nosound = true})
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
		g.draw(image, self.x, ctx.map.height - ctx.map.groundHeight, self.angle, self.burstScale * 2, self.burstScale * 2, image:getWidth() / 2, image:getHeight() / 2)
	else
		g.setColor(255, 255, 255)
    local image = data.media.graphics.spell.spujuSkull
		g.draw(image, self.x, self.y, self.angle, self.scale, self.scale, image:getWidth() / 2, image:getHeight() / 2)
	end
end

return SpujuSkull
