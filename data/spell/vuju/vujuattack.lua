local VujuAttack = extend(Spell)

function VujuAttack:activate()
  self.direction = math.sign(self.target.x - self.unit.x)
  self.x = self.unit.x + self.unit.width / 2 * self.direction
  self.y = self.unit.y - self.unit.height / 3
  self.angle = -self.direction * math.pi
  self.speed = 300
  self.width = 32
  ctx.event:emit('view.register', {object = self})
end

function VujuAttack:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function VujuAttack:update()
  self.x = self.x + math.dx(self.speed * ls.tickrate, 0) * self.direction
  if not self.target or math.abs(self.x - self.target.x) < self.width / 2 or math.sign(self.target.x - self.x) ~= self.direction then
    if self.target.buffs then
      self.target.buffs:add('vujuattackdot', {timer = 4, dot = self.unit.damage})
    else
      self.unit:attack({target = self.target, damage = self.unit.damage})
    end
    ctx.spells:remove(self)
  end
end

function VujuAttack:draw()
  if not self.target then return end
  local g = love.graphics
  g.setColor(255, 0, 0, 255 * (self.target.alpha or 1))
  g.circle('fill', self.x, self.y, 7)
end

return VujuAttack
