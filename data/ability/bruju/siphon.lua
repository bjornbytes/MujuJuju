local Siphon = extend(Ability)

function Siphon:postattack(target, amount)
  if amount then
    local lifesteal = .05 + amount * (.05 * self.unit:upgradeLevel('siphon'))

    if self.unit:upgradeLevel('equilibrium') > 0 and self.unit.health < self.unit.maxHealth * .4 then
      lifesteal = lifesteal * 2
    end

    self.unit:heal(lifesteal)
  end
end

return Siphon
