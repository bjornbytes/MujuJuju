local TrinketKnockback = extend(Buff)
TrinketKnockback.code = 'trinketknockback'
TrinketKnockback.name = 'Trinket'
TrinketKnockback.tags = {'knockback'}

function TrinketKnockback:update()
  local sign = math.sign(self.offset)
  local amount = math.ceil(math.max(math.abs(self.offset) * tickRate / .1, 100 * tickRate))

  if ctx.tag == 'server' then self.unit.x = self.unit.x + amount * sign end

  self.offset = self.offset - (amount * sign)
  if self.offset == 0 then self.unit.buffs:remove(self) end
end

return TrinketKnockback
