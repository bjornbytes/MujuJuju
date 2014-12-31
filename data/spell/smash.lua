local Smash = class()
Smash.code = 'smash'

Smash.maxHealth = 1

function Smash:activate()
  self.y = self.y or (ctx.map.height - ctx.map.groundHeight - data.unit.thuju.height)
	self.health = self.maxHealth
  if self.damage and self.stun then
    table.each(ctx.target:inRange(self, self.range, 'enemy', 'unit'), function(target)
      if math.sign(target.x - self.owner.x) == self.direction then
        target:hurt(self.damage, self.owner)
        target:addBuff('stun', self.stun, self.stun, self.owner, 'smashStun')
        -- damage and stun
      end
    end)
  end
  ctx.event:emit('view.register', {object = self})
end

function Smash:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Smash:update()
	self.health = timer.rot(self.health, function() ctx.spells:remove(self) end)
end

function Smash:draw()
	local g = love.graphics
	g.setColor(255, 255, 255, self.health / self.maxHealth)
  g.circle('line', self.x + self.range / 2 * self.direction, self.y, self.range / 2)
end

return Smash
