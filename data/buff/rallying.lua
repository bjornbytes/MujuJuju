local Rallying = extend(Buff)
Rallying.tags = {'elite'}

function Rallying:preattack(target, damage)
  local units = ctx.target:inRange(self.unit, self.range, 'ally', 'unit')

  table.each(units, function (unit)
    unit.buffs:add('rallyingfury', {
      damage = self.damageModifier
    })
  end)

  return damage * self.damageModifier
end

return Rallying
