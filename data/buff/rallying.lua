local Rallying = extend(Buff)
Rallying.tags = {'elite'}

function Rallying:update()
  local units = ctx.target:inRange(self.unit, self.range, 'ally', 'unit')

  table.each(units, function(unit)
    unit.buffs:add('rallyingfury', {
      haste = self.speedModifier,
      timer = .5
    })
  end)
end

return Rallying
