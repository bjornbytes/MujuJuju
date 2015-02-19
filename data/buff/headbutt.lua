local Headbutt = extend(Buff)
Headbutt.tags = {'knockback', 'knockup'}

function Headbutt:activate()
  self.base = math.abs(self.offset)
end

function Headbutt:update()
  local sign = math.sign(self.offset)
  local knockbackFactor = math.max(math.abs(self.offset) / self.base, .5) * 600 * ls.tickrate
  local amount = knockbackFactor

  self.unit.x = self.unit.x + amount * sign

  local knockupFactor = 1 - (2 * math.abs(.5 - math.abs(self.offset / self.base)))
  self.knockup = knockupFactor * 25

  self.offset = self.offset - math.min(math.abs(amount * sign), math.abs(self.offset)) * math.sign(self.offset)
  if self.offset == 0 then self.unit.buffs:remove(self) end
end

return Headbutt
