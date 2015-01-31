local RallyingFury = extend(Buff)
RallyingFury.tags = {}

function RallyingFury:preattack(target, damage)
  return damage * self.damageModifier
end


return RallyingFury
