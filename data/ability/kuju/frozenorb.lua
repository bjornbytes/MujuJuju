local FrozenOrb = extend(Ability)

FrozenOrb.damage = 0
FrozenOrb.slow = 0
FrozenOrb.knockback = 0

----------------
-- Behavior
----------------
function FrozenOrb:activate()
  self.timer = love.math.random() * 10 - self.unit:upgradeLevel('frozenorb')

  self.unit.animation:on('event', function(event)
    if event.data.name == 'frozenorb' then
      ctx.sound:play(data.media.sounds.kuju.frozenorb)
      self:createSpell('frozenorb', {})
      self.timer = 10 - self.unit:upgradeLevel('frozenorb')
    end
  end)
end

function FrozenOrb:use()
  if self.unit.target and not isa(self.unit.target, Shrine) then
    self.unit.animation:set('frozenorb')
    self.unit.casting = true
  end
end

return FrozenOrb

