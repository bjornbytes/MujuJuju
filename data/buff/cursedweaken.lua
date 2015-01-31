local CursedWeaken = extend(Buff)
CursedWeaken.tags = {}

function CursedWeaken:preattack(target, damage)
  return damage * self.weakenModifier
end

return CursedWeaken
