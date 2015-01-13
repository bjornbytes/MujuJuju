local Civilization = extend(Shruju)

Civilization.code = 'civilization'
Civilization.name = 'Civilization'
Civilization.description = 'Increases the maximum number of minions you may summon at once by 3.'
Civilization.duration = 90
Civilization.rarity = 1

function Civilization:activate()
  ctx.player.maxPopulation = ctx.player.maxPopulation + 3
end

function Civilization:deactivate()
  ctx.player.maxPopulation = ctx.player.maxPopulation - 3
end

return Civilization
