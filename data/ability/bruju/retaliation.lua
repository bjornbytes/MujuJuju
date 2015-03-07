local Retaliation = extend(Ability)

Retaliation.frenzy = .3
Retaliation.runeFrenzy = 0

function Retaliation:update()
  if self.unit.player and self.unit.player.dead then
    self.unit.buffs:add('retaliation', {frenzy = self.runeFrenzy + self.frenzy})
  else
    self.unit.buffs:remove('retaliation')
  end
end

function Retaliation:bonuses()
  local bonuses = {}
  if self.runeFrenzy > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeFrenzy * 100) .. '%', 'attack speed'})
  end
  return bonuses
end

return Retaliation
