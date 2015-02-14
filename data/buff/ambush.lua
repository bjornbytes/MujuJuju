local Ambush = extend(Buff)
Ambush.tags = {}

function Ambush:activate()
  self.unit.animation:set('vanish', {force = true})
  self.unit.animation:on('event', function(event)
    if event.data.name == 'vanished' then
      self.timer = 3
      self.unit.visible = false
    end
  end)
end

function Ambush:deactivate()
  local target = ctx.target:closest(self.unit, 'enemy', 'unit')
  self.unit.x = target.x + (target.animation.flipped and -1 or 1) * (self.unit.width / 2)
  self.unit.visible = true
end

return Ambush
