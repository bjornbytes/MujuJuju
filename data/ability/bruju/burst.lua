local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damage = 5 + (15 * self.unit:upgradeLevel('burst')) + (self.unit.damage * .5)
  local range = 85 + (6 * self.unit:upgradeLevel('burst'))

  local sanctuary = self.unit:upgradeLevel('sanctuary')
  local heal = 0
  if sanctuary > 0 then
    heal = (10 + 10 * sanctuary) + (.1 + (.2 * sanctuary) * damage)
  end

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

return Burst
