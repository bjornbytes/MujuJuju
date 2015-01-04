local Siphon = extend(Ability)
Siphon.code = 'siphon'

function Siphon:postattack(target, amount)
  local lifesteal = amount * (.1 * self.unit:upgradeLevel('siphon'))
  self.unit:heal(lifesteal)
end

return Siphon
