local Sinister = extend(Buff)
Sinister.code = 'sinister'
Sinister.name = 'Sinister'
Sinister.tags = {'elite'}

function Sinister:preattack(target, damage)
  return damage * self.damageModifier
end

return Sinister
