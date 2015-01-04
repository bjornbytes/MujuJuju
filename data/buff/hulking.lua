local Hulking = extend(Buff)
Hulking.code = 'hulking'
Hulking.name = 'Hulking'
Hulking.tags = {'slow', 'elite'}

function Hulking:activate()
  self.unit.health = self.unit.health + self.unit.health * self.healthModifier
  self.unit.maxHealth = self.unit.health
end

return Hulking
