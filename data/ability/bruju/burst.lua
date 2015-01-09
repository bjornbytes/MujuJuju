local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damage = 10 + (20 * (self.unit:upgradeLevel('burst') - 1)) + (self.unit.damage * (.5 + self.unit:upgradeLevel('burst') / 10))
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
