local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damage = 25 * self.unit:upgradeLevel('burst')
  local range = 85 + (6 * self.unit:upgradeLevel('burst'))
  local heal = 10 + 5 * self.unit:upgradeLevel('sanctuary')

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = heal > 0 and (2 + self.unit:upgradeLevel('sanctuary')) or .5
  })
end

return Burst
