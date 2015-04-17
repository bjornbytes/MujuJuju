local Avalanche = extend(Buff)
Avalanche.tags = {'knockback', 'knockup'}

function Avalanche:activate()
  self.base = math.abs(self.offset)
end

function Avalanche:update()
  local sign = lume.sign(self.offset)
  local knockbackFactor = math.max(math.abs(self.offset) / self.base, .5) * 600 * ls.tickrate
  local amount = knockbackFactor

  self.unit.x = math.clamp(self.unit.x + amount * sign, 0, ctx.map.width)

  local knockupFactor = 1 - (2 * math.abs(.5 - math.abs(self.offset / self.base)))
  self.knockup = knockupFactor * 25

  self.offset = self.offset - math.min(math.abs(amount * sign), math.abs(self.offset)) * lume.sign(self.offset)
  if self.offset == 0 then self.unit.buffs:remove(self) end
end

return Avalanche
