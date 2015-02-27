local Ambush = extend(Buff)
Ambush.tags = {}

function Ambush:activate()
  self.unit.animation:set('vanish', {force = true})
  self.unit.animation:on('event', function(event)
    if event.data.name == 'vanish' then
      self.timer = 3
      self.unit.visible = false
      self.unit.untargetable = true
    end
  end)
end

function Ambush:deactivate()
  local target = ctx.target:closest(self.unit, 'enemy', 'unit')
  if target then
    self.unit.x = target.x - (target.animation.flipped and -1 or 1) * (self.unit.width / 2)
  end

  self.unit.visible = true
  self.unit.untargetable = false
  self.unit.animation:set('idle', {force = true})
end

return Ambush
