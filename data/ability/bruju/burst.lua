local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damage = 10 + (20 * (self.unit:upgradeLevel('burst') - 1)) + (self.unit.damage * (.5 + self.unit:upgradeLevel('burst') / 10))
  local range = 85 + (6 * self.unit:upgradeLevel('burst'))
  local heal = (10 + 20 * self.unit:upgradeLevel('sanctuary')) * (self.unit:upgradeLevel('sanctuary') > 0 and 1 or 0)

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

return Burst
