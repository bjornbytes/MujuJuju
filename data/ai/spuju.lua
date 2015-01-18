local Spuju = extend(UnitAI)

function Spuju:update()
  if ctx.player.dead then
    self.unit.untargetable = true
    self:moveTowards(ctx.shrine)
  else
    self.unit.untargetable = false
    UnitAI.update(self)
  end
end

return Spuju
