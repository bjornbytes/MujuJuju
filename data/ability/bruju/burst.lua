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
  local heal = sanctuary > 0 and damage * .5 or 0

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal,
    maxHealth = .5
  })
end

function Burst:bonuses()
  local bonuses = {}
  local spirit = Unit.getStat('bruju', 'spirit')
  local eruption = data.unit.bruju.upgrades.eruption.level

  if eruption > 0 then
    table.insert(bonuses, {'Eruption', self.ranges[eruption] - self.ranges[0], 'range'})
  end

  if spirit > 0 then
    table.insert(bonuses, {'Spirit', spirit * self.spiritRatio, 'damage'})
  end

  if self.runeDamage > 0 then
    table.insert(bonuses, {'Runes', self.runeDamage, 'damage'})
  end

  if self.runeRange > 0 then
    table.insert(bonuses, {'Runes', self.runeRange, 'range'})
  end
  return bonuses
end

return Burst
