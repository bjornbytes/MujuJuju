local Burst = extend(Ability)
Burst.code = 'burst'

function Burst:die()
  local damages = {20, 40, 70, 110, 160}
  local ranges = {[0] = 60, 80, 110, 150}
  local burst = self.unit:upgradeLevel('burst')
  local eruption = self.unit:upgradeLevel('eruption')
  local sanctuary = self.unit:upgradeLevel('sanctuary')

  local damage = damages[burst]
  local range = ranges[eruption]
  local heal = 0

  heal = sanctuary > 0 and damage * .5 or 0

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

return Burst
