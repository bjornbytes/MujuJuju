local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damage = self.unit:upgradeLevel('burst') * 40
  local range = 85-- + (6 * self.unit:upgradeLevel('burst'))
  local heal = self.unit:upgradeLevel('sanctuary') * 30

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

return Burst
