local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damage = 0--5 + (15 * self.unit:upgradeLevel('burst')) + (self.unit.damage * .5)
  local range = 85-- + (6 * self.unit:upgradeLevel('burst'))
  local heal = 40

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

return Burst
