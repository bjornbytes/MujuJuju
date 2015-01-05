local Population = class()

Population.code = 'population'
Population.name = 'Population'
Population.description = 'On use, increases the maximum number of minions you can have summoned at a time by 1.'

Population.time = 60

function Population:eat()
 local p = ctx.players:get(ctx.id)
 p.maxPopulation = p.maxPopulation + 1
end

return Population
