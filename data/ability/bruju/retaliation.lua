local Retaliation = extend(Ability)

Retaliation.frenzy = .3

function Retaliation:update()
  if self.unit.player and self.unit.player.dead then
    self.unit.buffs:add('retaliation', {frenzy = self.frenzy})
  else
    self.unit.buffs:remove('retaliation')
  end
end

return Retaliation
