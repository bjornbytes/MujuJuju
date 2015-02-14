local Teleport = extend(Ability)

----------------
-- Data
----------------
Teleport.cooldown = 15


----------------
-- Behavior
----------------
function Teleport:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'teleport' then
      self.unit.x = ctx.map.width - self.unit.x
    end
  end)
end

function Teleport:use()
  self.unit.animation:set('teleport')
  if self.unit.animation.state.name == 'teleport' then
    self.unit.casting = true
    self.timer = self.cooldown
  end
end

return Teleport
