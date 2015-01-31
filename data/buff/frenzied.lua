local Frenzied = extend(Buff)
Frenzied.tags = {'elite', 'frenzy', 'haste'}

function Frenzied:active()
  self.unit.health = self.unit.health + self.unit.health * self.healthModifier
  self.unit.maxHealth = self.unit.health
end

return Frenzied
