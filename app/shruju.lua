Shruju = class()

function Shruju:eat()
  self:activate()
  if self.duration then
    self.timer = self.duration
    local p = ctx.player
    table.insert(p.shruju, self)
  end
end
