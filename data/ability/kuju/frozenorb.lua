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
FrozenOrb.cooldown = 6
FrozenOrb.damage = 10
FrozenOrb.range = 200
FrozenOrb.radius = 15
FrozenOrb.speed = 400
FrozenOrb.duration = 2
FrozenOrb.slow = .6


----------------
-- Behavior
----------------
function FrozenOrb:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'frozenorb' then
      ctx.sound:play(data.media.sounds.kuju.frozenorb)
      self:createSpell('frozenorb', {
        damage = self.damage,
        range = self.range,
        radius = self.radius,
        speed = self.speed,
        slow = self.slow,
        duration = self.duration
      })
    end
  end)
end

function FrozenOrb:use()
  self.unit.animation:set('frozenorb')
  self.unit.casting = true
  self.timer = self.cooldown
end

return FrozenOrb

