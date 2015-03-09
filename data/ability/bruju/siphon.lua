local Siphon = extend(Ability)

Siphon.runeLifesteal = 0

function Siphon:postattack(target, amount)
  if amount then
    local lifesteal = self.runeLifesteal + (.04 + amount * (.04 * self.unit:upgradeLevel('siphon')))

    if self.unit:upgradeLevel('equilibrium') > 0 and self.unit.health < self.unit.maxHealth * .4 then
      lifesteal = lifesteal * 2
    end

    self.unit:heal(lifesteal)
  end
end

function Siphon:bonuses()
  local bonuses = {}
  if self.runeLifesteal > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeLifesteal * 100) .. '%', 'lifesteal'})
  end
  return bonuses
end

return Siphon
