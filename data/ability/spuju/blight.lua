local Blight = extend(Ability)

function Blight:die()
  self:createSpell({
    damage = self.unit.damage * 2,
    range = 70,
    maxHealth = .5
  })
end

return Blight
