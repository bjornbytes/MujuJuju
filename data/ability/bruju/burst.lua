local Burst = extend(Ability)

Burst.runeDamage = 0
Burst.runeRange = 0

Burst.damages = {20, 40, 70, 110, 160}
Burst.spiritRatio = 1

Burst.ranges = {[0] = 60, 80, 110, 150}

function Burst:die()
  local damages = self.damages
  local burst = self.unit:upgradeLevel('burst')
  local eruption = self.unit:upgradeLevel('eruption')
  local sanctuary = self.unit:upgradeLevel('sanctuary')

  local damage = self.runeDamage + damages[burst] + self.spiritRatio * self.unit.spirit
  local range = self.runeRange + self.ranges[eruption]
  local heal = 0

  heal = sanctuary > 0 and damage * .5 or 0
  heal = heal

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

function Burst:bonuses()
  local bonuses = {}
  local unit = self.unit
  local eruption = unit:upgradeLevel('eruption')
  if eruption > 0 then
    local baseRange = self.ranges[0]
    table.insert(bonuses, {'Eruption', self.ranges[eruption] - baseRange, 'range'})
  end
  if unit.spirit > 0 then
    local damageBonus = self.spiritRatio * unit.spirit
    table.insert(bonuses, {'Spirit', damageBonus, 'damage'})
  end
  return bonuses
end

return Burst
