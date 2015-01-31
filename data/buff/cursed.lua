local Cursed = extend(Buff)
Cursed.tags = {'elite'}

function Cursed:update(target, damage)
  ctx.units:each(function(unit)
    unit.buffs:remove('cursedweaken')
  end)

  local units = ctx.target:inRange(self.unit, self.range, 'enemy', 'unit')
  table.each(units, function(unit)
    unit.buffs:add('cursedweaken', {
      weakenModifier = self.weakenModifier
    })
  end)

  return damage
end

return Cursed
