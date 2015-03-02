local TwinBlades = extend(Buff)
TwinBlades.tags = {}

function TwinBlades:activate()
  self.dirtyTimer = 0
end

function TwinBlades:update()
  self.dirtyTimer = timer.rot(self.dirtyTimer)
end

function TwinBlades:preattack(target, amount)
  local secondTarget, distance = ctx.target:closest(target, 'ally', 'unit')
  if secondTarget and distance < 50 and self.dirtyTimer == 0 then
    self.dirtyTimer = ls.tickrate
    self.unit:attack({target = secondTarget})
  end
end

return TwinBlades
