local Charge = extend(Ability)

----------------
-- Meta
----------------
Charge.name = 'Charge'
Charge.description = [[
Duju charges forward through his enemies.
Any enemies caught in his path are damaged and slowed for a short duration.
]]


----------------
-- Data
----------------
Charge.cooldown = 5

Charge.damage = 5
Charge.range = 125
Charge.speed = 625
Charge.slowDuration = 2
Charge.slow = .25


----------------
-- Behavior
----------------
function Charge:use()
  if self:hasUpgrade('trample') then
    self.damage = self.damage + self.damage * Trample.damageModifier
    self.stunDuration = Trample.stunDuration
  end

  if self:hasUpgrade('tenacity') then
    self.range = self.range * Tenacity.distanceModifier
    self.unit.buffs:add('chargearmor', {
      timer = Tenacity.mitigationDuration,
      armor = Tenacity.mitigationModifier
    })
  end

  ctx.spells:add(data.spell.duju.charge, {
    damage = self.damage,
    range = self.range,
    speed = self.speed,
    slow = self.slow,
    duration = self.stunDuration or self.slowDuration,
    ability = self
  })
end


----------------
-- Upgrades
----------------
local Trample = {}
Trample.name = 'Trample'
Trample.code = 'trample'
Trample.damageModifier = .5
Trample.stunDuration = 1
Trample.description = 'Charge deals %damageModifier more damage and now stuns for $stunDuration seconds in place of Duju\'s slowing effect.'

local Tenacity = {}
Tenacity.name = 'Tenacity'
Tenacity.code = 'tenacity'
Tenacity.distanceModifier = 2
Tenacity.mitigationModifier = .5
Tenacity.mitigationDuration = 3
Tenacity.description = 'Duju charges twice as far, and gains %mitigationModifier damage reduction for $mitigationDuration seconds during and after the charge.'

Charge.upgrades = {Trample, Tenacity}

return Charge

