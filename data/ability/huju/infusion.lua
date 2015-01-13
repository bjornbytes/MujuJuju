local Infusion = extend(Ability)

----------------
-- Meta
----------------
Infusion.name = 'Infusion'
Infusion.description = 'Huju plants itself in the ground like a boss, channeling for $duration second$s.  During this time, nearby allies are healed for a total of %maxHealthHeal of their maximum health.  This ability costs %currentHealthCost of Huju\'s current health to use.'


----------------
-- Data
----------------
Infusion.cooldown = 8
Infusion.range = 150
Infusion.duration = 5
Infusion.currentHealthCost = .2
Infusion.maxHealthHeal = .3


----------------
-- Behavior
----------------
function Infusion:activate()
  self.channelTimer = 0
end

function Infusion:update()
  self.channelTimer = timer.rot(self.channelTimer, function()
    self.unit.channeling = false
  end)
end

function Infusion:use()
  self.unit:hurt(self.unit.health * self.currentHealthCost, self.unit)
  self.unit.channeling = true
  self.channelTimer = self.duration
  self:createSpell()
end


----------------
-- Upgrades
----------------
local Distortion = {}
Distortion.code = 'distortion'
Distortion.name = 'Distortion'
Distortion.description = 'Infusion creates some void zone thing that hastes allies in the area by %haste and slows enemies in the area by %slow.'
Distortion.slow = .5
Distortion.haste = .5

local Resilience = {}
Resilience.code = 'resilience'
Resilience.name = 'Resilience'
Resilience.description = 'Any allies under the effect of infusion become immune to crowd control effects.'

Infusion.upgrades = {Distortion, Resilience}

return Infusion
