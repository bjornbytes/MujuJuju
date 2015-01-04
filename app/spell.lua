Spell = class()

function Spell:getAbility()
  return self.ability
end

function Spell:getUnit()
  return self.ability.unit
end

function Spell:getUnitDirection()
  return self:getUnit().animation.flipped
end

function Spell:getPlayer()
  return self.ability.unit.player
end
