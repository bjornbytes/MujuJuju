local VujuAttack = extend(Spell)

function VujuAttack:activate()
  ctx.particles:emit('vujuattack', self.target.x, self.target.y - self.target.height / 2, 12)
  if isa(self.target, Unit) then
    self.target.buffs:add('vujuattackdot', {timer = 4, dot = self.unit.damage})
  else
    self.unit:attack({target = self.target, damage = self.unit.damage})
  end
  ctx.spells:remove(self)
end

return VujuAttack
