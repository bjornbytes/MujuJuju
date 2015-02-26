local Burst = extend(Ability)

Burst.damage = 0
Burst.range = 0

Burst.damages = {20, 40, 70, 110, 160}
Burst.spiritRatio = 1

function Burst:die()
  local damages = self.damages
  local ranges = {[0] = 60, 80, 110, 150}
  local burst = self.unit:upgradeLevel('burst')
  local eruption = self.unit:upgradeLevel('eruption')
  local sanctuary = self.unit:upgradeLevel('sanctuary')

  local damage = damages[burst] + self.spiritRatio * self.unit.spirit
  local range = ranges[eruption]
  local heal = 0

  heal = sanctuary > 0 and damage * .5 or 0
  heal = heal

  self:createSpell({
    damage = self.damage + damage,
    range = self.range + range,
    heal = heal,
    maxHealth = .5
  })
end

return Burst
