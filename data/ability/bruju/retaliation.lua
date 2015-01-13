local Retaliation = extend(Ability)
Retaliation.code = 'retaliation'

function Retaliation:update()
  if self.unit.player and self.unit.player.dead then
    self.unit.buffs:add('retaliation')
  else
    self.unit.buffs:remove('retaliation')
  end
end

return Retaliation