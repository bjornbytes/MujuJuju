local Teleport = extend(Ability)

----------------
-- Data
----------------
Teleport.cooldown = 5
Teleport.knockbackDistance = 100
Teleport.damageModifier = 1.25


----------------
-- Behavior
----------------
function Teleport:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'teleport' then
      self.unit.x = ctx.map.width - self.unit.x
    end
  end)

  self.unit.animation:on('complete', function(data)
    if data.state.name == 'teleport' then
      self.unit.untargetable = false
    end
  end)
end

function Teleport:use()
  self.unit.animation:set('teleport')
  self.unit.untargetable = true
  self.unit.casting = true
  self.timer = self.cooldown
end

return Teleport
