local Trinket = extend(Ability)
Trinket.code = 'trinket'

----------------
-- Meta
----------------
Trinket.name = 'Trinket'
Trinket.description = 'Huju entrusts a target ally with a trinket for $duration second$s.  The trinket increases the movement speed of the ally by %haste, and also increases their attack speed by %frenzy.'


----------------
-- Data
----------------
Trinket.cooldown = 15
Trinket.target = 'ally'
Trinket.range = 200
Trinket.duration = 4
Trinket.frenzy = .3
Trinket.haste = .4


----------------
-- Behavior
----------------
function Trinket:use(target)
  self:createSpell({target = target})
end


----------------
-- Upgrades
----------------
local Imbue = {}
Imbue.code = 'imbue'
Imbue.name = 'Imbue'
Imbue.description = 'When the trinket expires, the ally is healed for $heal health and all cooldowns of the ally are reduced by $cooldownReduction seconds.'
Imbue.heal = 75
Imbue.cooldownReduction = 3

local Surge = {}
Surge.code = 'surge'
Surge.name = 'Surge'
Surge.description = 'The trinket explodes when it expires, dealing $damage damage to all nearby enemies and knocking them back a short distance.'
Surge.damage = 75
Surge.range = 100
Surge.knockback = 100

Trinket.upgrades = {Imbue, Surge}

return Trinket
