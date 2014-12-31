local Tremor = extend(Ability)
Tremor.code = 'tremor'

----------------
-- Meta
----------------
Tremor.name = 'Tremor'
Tremor.description = 'Thuju slams the ground in the direction he is facing, causing the tectonic plates of the Earth to erupt in front of him.  Any enemies unfortunate enough to be caught in the area of impact take $damage damage and are stunned for $stun second$s.'


----------------
-- Data
----------------
Tremor.cooldown = 5
Tremor.damage = 40
Tremor.stun = .75
Tremor.width = 125


----------------
-- Behavior
----------------
function Tremor:use()
  local width, stun, silence, structureDamageMultiplier = self.width, self.stun, nil, nil

  if self:hasUpgrade('concussion') then
    stun = self.upgrades.concussion.stun
    silence = self.upgrades.concussion.silence
  end

  if self:hasUpgrade('fissure') then
    width = width * self.upgrades.fissure.widthMultiplier
    structureDamageMultiplier = self.upgrades.fissure.structureDamageMultiplier
  end

  self:createSpell({width = width, stun = stun, silence = silence, structureDamageMultiplier = structureDamageMultiplier})
end


----------------
-- Upgrades
----------------
local Concussion = {}
Concussion.code = 'concussion'
Concussion.name = 'Concussion'
Concussion.description = 'Tremor now gives enemies a concussion, increasing the stun to $stun second$s and applying a $silence second silence.'
Concussion.stun = 1.5
Concussion.silence = 4

local Fissure = {}
Fissure.code = 'fissure'
Fissure.name = 'Fissure'
Fissure.description = 'Thuju slams with increased force, creating a fissure in the ground.  The width of Tremor is %widthMultiplier of the normal width.  Additionally, tremor deals %structureDamageMultiplier damage to structures.'
Fissure.widthMultiplier = 2
Fissure.structureDamageMultiplier = 2

Tremor.upgrades = {Concussion, Fissure}

return Tremor
