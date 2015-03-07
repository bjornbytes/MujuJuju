local VujuAttack = extend(Spell)

function VujuAttack:activate()
  if isa(self.target, Unit) then
    ctx.particles:emit('vujuattack', self.target.x, self.target.y - self.target.height / 2, 12)
    self.target.buffs:add('vujuattackdot', {timer = 4, dot = self.unit.damage, noparticles = true})
  else
    self.unit:attack({target = self.target, damage = self.unit.damage, noparticles = true})
  end
  ctx.spells:remove(self)
end

return VujuAttack
