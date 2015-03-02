local Frenzied = extend(Buff)
Frenzied.tags = {'elite', 'frenzy', 'haste'}

function Frenzied:activate()
  self.unit.health = self.unit.health + self.unit.health * self.healthModifier
  self.unit.maxHealth = self.unit.health
end

return Frenzied
