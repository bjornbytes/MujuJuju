local TauntDamage = extend(Buff)
TauntDamage.tags = {'damage'}

function TauntDamage:preattack(target, damage)
  return damage + self.damage
end

return TauntDamage
