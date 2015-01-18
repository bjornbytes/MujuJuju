local KujuAttack = extend(Spell)

function KujuAttack:activate()
  self.direction = math.sign(self.target.x - self.unit.x)
  self.x = self.unit.x + self.unit.width / 2 * self.direction
  self.y = self.unit.y - self.unit.height / 3
  self.angle = -self.direction * math.pi
  self.speed = 300
  self.width = 32
  ctx.event:emit('view.register', {object = self})
end

function KujuAttack:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function KujuAttack:update()
  self.x = self.x + math.dx(self.speed * tickRate, 0) * self.direction
  if not self.target or math.abs(self.x - self.target.x) < self.width / 2 then
    self.unit:attack({target = self.target, damage = self.unit.damage})
    if self.target.buffs then
      self.target.buffs:add('kujuattackslow', {timer = 1, amount = .1})
      local buff = self.target.buffs:get('kujuattackslow')
      buff.slow = buff.stacks * .1
    end
    ctx.spells:remove(self)
  end
end

function KujuAttack:draw()
  if not self.target then return end
  local g = love.graphics
  g.setColor(255, 255, 255, 255 * (self.target.alpha or 1))
  local image = data.media.graphics.spell.kujuattack
  local scale = self.width / image:getWidth()
  g.draw(image, self.x, self.y, 0, -self.direction * scale, scale, image:getWidth() / 2, image:getHeight() / 2)
end

return KujuAttack
