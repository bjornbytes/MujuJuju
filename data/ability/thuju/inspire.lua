local Inspire = extend(Ability)

function Inspire:activate()
  local range = 150
  local level = self.unit:upgradeLevel('inspire')
  local targets = ctx.target:inRange(self.unit, range, 'ally', 'unit')
  table.each(targets, function(target)
    target.buffs:add('inspire', {
      timer = 3,
      haste = .5,
      armor = level >= 2 and .5 or 0,
      frenzy = level >= 3 and .3 or 0
    })
  end)
end

return Inspire
