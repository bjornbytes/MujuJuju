local Burst = extend(Ability)
Burst.code = 'burst'

----------------
-- Meta
----------------
Burst.name = 'Burst'
Burst.description = 'Bruju ignites into a spirit flame on death, dealing $damage damage to nearby enemies.'


----------------
-- Data
----------------
Burst.passive = true
Burst.damage = 50
Burst.range = 100


----------------
-- Behavior
----------------
function Burst:die()
  local damage = self.damage
  local range = self.range
  local heal = 0

  if self:hasUpgrade('essenceFlame') then
    damage = damage + damage * self.upgrades.essenceflame.damageIncrease
    range = range + range * self.upgrades.essenceflame.rangeIncrease
  end

  if self:hasUpgrade('sanctuary') then
    heal = self.upgrades.sanctuary.maxHealthHeal
  end

  self:createSpell({
    damage = damage,
    range = range,
    heal = heal
  })
end


----------------
-- Upgrades
----------------
local EssenceFlame = {}
EssenceFlame.code = 'essenceflame'
EssenceFlame.name = 'Essence Flame'
EssenceFlame.description = 'Burst deals %damageIncrease more damage and the radius is increased by %rangeIncrease.'
EssenceFlame.damageIncrease = .5
EssenceFlame.rangeIncrease = .2

local Sanctuary = {}
Sanctuary.code = 'sanctuary'
Sanctuary.name = 'Sanctuary'
Sanctuary.description = 'Burst instantly heals all allies in the area of effect for %maxHealthHeal of their maximum health.'
Sanctuary.maxHealthHeal = .15

Burst.upgrades = {EssenceFlame, Sanctuary}

return Burst
