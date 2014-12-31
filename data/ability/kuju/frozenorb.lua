local FrozenOrb = extend(Ability)
FrozenOrb.code = 'frozenorb'

----------------
-- Meta
----------------
FrozenOrb.name = 'Frozen Orb'
FrozenOrb.description = 'Kuju sends out a frozen orb in the direction she is facing that deals $damage damage and slows units hit by %slow for $duration second$s.  It then returns to Kuju, hitting enemies a second time.'


----------------
-- Data
----------------
FrozenOrb.cooldown = 5

FrozenOrb.damage = 30
FrozenOrb.range = 175
FrozenOrb.radius = 15
FrozenOrb.speed = 400
FrozenOrb.duration = 2
FrozenOrb.slow = .25


----------------
-- Behavior
----------------
function FrozenOrb:use()
  local damage, range = self.damage, self.range

  if self:hasUpgrade('winterswrath') then
    damage = damage + damage * self.upgrades.winterswrath.damageIncrease
  end

  if self:hasUpgrade('sweepinggale') then
    range = range + range * self.upgrades.sweepinggale.rangeIncrease
  end

  self:createSpell({
    damage = damage,
    range = range,
    radius = self.radius,
    speed = self.speed,
    slow = self.slow,
    duration = self.duration
  })
end


----------------
-- Upgrades
----------------
local WintersWrath = {}
WintersWrath.name = 'Winter\'s Wrath'
WintersWrath.code = 'winterswrath'
WintersWrath.description = 'Frozen Orb deals %damageIncrease more damage.'
WintersWrath.damageIncrease = .25

local SweepingGale = {}
SweepingGale.name = 'Sweeping Gale'
SweepingGale.code = 'sweepinggale'
SweepingGale.description = 'Frozen orb travels %rangeIncrease further away from Kuju before returning.'
SweepingGale.rangeIncrease = .25

FrozenOrb.upgrades = {WintersWrath, SweepingGale}

return FrozenOrb

