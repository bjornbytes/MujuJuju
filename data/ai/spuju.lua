local Spuju = extend(UnitAI)

function Spuju:update()
  if ctx.player.dead then
    self.unit.untargetable = true
    self:moveTowards(ctx.shrine)
    self.unit.alpha = math.lerp(self.unit.alpha, 0, math.min(10 * tickRate, 1))
  else
    self.unit.untargetable = false
    UnitAI.update(self)
  end
end

return Spuju
