local KujuAttack = extend(Spell)

function KujuAttack:activate()
  self.direction = lume.sign(self.target.x - self.unit.x)
  self.x = self.unit.x + self.unit.width / 2 * self.direction
  self.prevx = self.x
  self.y = self.unit.y - self.unit.height / 3
  self.team = self.unit.team
  self.angle = -self.direction * math.pi
  self.speed = 300
  self.width = 32
  ctx.event:emit('view.register', {object = self})
end

function KujuAttack:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function KujuAttack:update()
  local unit = self.unit
  self.prevx = self.x
  self.x = self.x + math.dx(self.speed * ls.tickrate, 0) * self.direction
  if not self.target or math.abs(self.x - self.target.x) < self.width / 2 or lume.sign(self.target.x - self.x) ~= self.direction then
    unit:attack({target = self.target, damage = unit.damage, noparticles = true})
    ctx.particles:emit('kujuattack', self.x, self.y, 1)
    ctx.particles:emit('kujuattackhit', self.x, self.y, 1)

    local windchill = unit:upgradeLevel('windchill')
    if self.target.buffs and windchill > 0 then
      self.target.buffs:add('windchill', {slow = .2 * windchill, timer = .25 + .25 * windchill})
      self.target:hurt(unit.spirit * (.2 + .2 * windchill), unit)
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
  local x = lume.lerp(self.prevx, self.x, ls.accum / ls.tickrate)
  g.draw(image, x, self.y, 0, -self.direction * scale, scale, image:getWidth() / 2, image:getHeight() / 2)
end

return KujuAttack
