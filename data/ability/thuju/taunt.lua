local Taunt = extend(Ability)

function Taunt:postattack(target, damage)
  if target.buffs then
    target.buffs:add('taunt', {timer = 5, target = self.unit})
  end
end

return Taunt
