local Retaliation = extend(Ability)
Retaliation.code = 'retaliation'

function Retaliation:update()
  if self.unit.player and self.unit.player.dead then
    self.buffs:add('retaliation')
  else
    self.buffs:remove('retaliation')
  end
end

return Retaliation
