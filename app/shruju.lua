Shruju = class()

function Shruju:eat()
  self:activate()
  if self.effect then
    local p = ctx.player
    table.insert(p.shruju, self.effect)
  end
end
