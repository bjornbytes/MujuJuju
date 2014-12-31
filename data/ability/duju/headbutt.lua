local Headbutt = extend(Ability)
Headbutt.code = 'headbutt'

----------------
-- Meta
----------------
Headbutt.name = 'Headbutt'
Headbutt.description = table.concat({
  'Duju\'s next attack transforms into a powerful headbutt.',
  'This attack deals extra damage and knocks the target back a short distance.',
  'Deals %structureDamageModifier more damage to structures than a normal attack.'
}, ' ')

----------------
-- Data
----------------
Headbutt.cooldown = 5

Headbutt.damageModifier = 1
Headbutt.knockbackDistance = 150
Headbutt.structureDamageModifier = .3


----------------
-- Behavior
----------------
function Headbutt:use()
  self.unit.buffs:add('headbutt', {
    ability = self
  })
end


----------------
-- Upgrades
----------------
local Bash = {}
Bash.name = 'Bash'
Bash.code = 'bash'
Bash.knockModifier = .5
Bash.stunDuration = 1
Bash.description = 'Duju knocks enemies back %knockModifier further and stuns them for $stunDuration seconds.'

local RazorHorns = {}
RazorHorns.name = 'RazorHorns'
RazorHorns.code = 'razorhorns'
RazorHorns.dot = 25
RazorHorns.slowAmount = .5
RazorHorns.duration = 3
RazorHorns.description = 'Headbutted enemies are impaled, causing them to take $dot damage per second and move %slowAmount slower for $duration second$s.'

Headbutt.upgrades = {Bash, RazorHorns}

return Headbutt

