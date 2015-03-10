local VujuAttack = extend(Spell)

function VujuAttack:activate()
  self.unit:attack({target = self.target, damage = self.unit.damage, noparticles = true})
  ctx.spells:remove(self)
end

return VujuAttack
