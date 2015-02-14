local Spuju = extend(UnitAI)

function Spuju:update()
  if ctx.player.dead then
    self.unit.untargetable = true
    self.unit.alpha = math.lerp(self.unit.alpha, 0, math.min(10 * tickRate, 1))
  else
    self.unit.untargetable = false
    self.unit.alpha = math.lerp(self.unit.alpha, 1, math.min(10 * tickRate, 1))
  end

  UnitAI.update(self)
end

return Spuju
