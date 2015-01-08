local TauntDamage = extend(Buff)
TauntDamage.code = 'tauntdamage'
TauntDamage.name = 'Taunt'
TauntDamage.tags = {'damage'}

function TauntDamage:preattack(target, damage)
  return damage + self.damage
end

return TauntDamage
