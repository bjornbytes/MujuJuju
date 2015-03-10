local Intimidate = extend(Ability)

function Intimidate:activate()
  local targets = ctx.target:inRange(self.unit, 200, 'enemy', 'unit')
  table.each(targets, function(target)
    if target.buffs and isa(target, Unit) then
      target.buffs:add('intimidate', {timer = 6})
    end
  end)
end

return Intimidate
