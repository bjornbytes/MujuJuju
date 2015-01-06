Shruju = class()

function Shruju:eat()
  self:apply()
  if self.effect then
    local p = ctx.players:get(ctx.id)
    table.insert(p.magicShruju, self)
    self.effect:activate()
  end
end
