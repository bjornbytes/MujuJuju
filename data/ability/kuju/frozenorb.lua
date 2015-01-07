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
  --
end

return FrozenOrb

