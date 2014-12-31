local Siphon = extend(Ability)
Siphon.code = 'siphon'

----------------
-- Meta
----------------
Siphon.name = 'Siphon'
Siphon.description = 'Bruju passively siphons life from his enemies with every strike.  Siphon can be activated to temporarily intensify the effect, however the passive effect is lost while the ability recharges.'


----------------
-- Data
----------------
Siphon.cooldown = 12
Siphon.duration = 6
Siphon.lifesteal = .2
Siphon.activeLifesteal = .4


----------------
-- Behavior
----------------
function Siphon:update()
  if not self.unit.buffs:get('siphon') then
    self.buff = self.unit.buffs:add('siphon', {ability = self})
  end
end

function Siphon:deactivate()
  self.unit.buffs:remove(self.buff)
end

function Siphon:ready()
  self.buff:setPassive()
end

function Siphon:use()
  self.buff:setActive()
end


----------------
-- Upgrades
----------------
local Equilibrium = {}
Equilibrium.code = 'equilibrium'
Equilibrium.name = 'Equilibrium'
Equilibrium.description = 'Increases the effect by $percentMissingMultiplier% for every 1% of missing health.'
Equilibrium.percentMissingMultiplier = 1

local Radiance = {}
Radiance.code = 'radiance'
Radiance.name = 'Radiance'
Radiance.description = 'Siphon equally distributes an additional %amountMultiplier of the heal amount to nearby allies.'
Radiance.range = 100
Radiance.amountMultiplier = .5

Siphon.upgrades = {Equilibrium, Radiance}

return Siphon
