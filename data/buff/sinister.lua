local Sinister = extend(Buff)
Sinister.tags = {'elite'}

function Sinister:preattack(target, damage)
  return damage * self.damageModifier
end

return Sinister
