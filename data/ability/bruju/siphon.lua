local Siphon = extend(Ability)
Siphon.code = 'siphon'

function Siphon:postattack(target, amount)
  if amount then
    local lifesteal = amount * (.2 + (.1 * self.unit:upgradeLevel('siphon')))
    self.unit:heal(lifesteal)
  end
end

return Siphon
