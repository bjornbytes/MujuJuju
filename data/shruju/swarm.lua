local Swarm = class()

Swarm.code = 'swarm'
Swarm.name = 'Swarm'
Swarm.description = 'On use, increases the maximum number of minions you can have summoned at a time by 1.'

Swarm.time = 60

function Swarm:eat()
 local p = ctx.players:get(ctx.id)
 p.maxPopulation = p.maxPopulation + 1
 ctx.hud.status.populationScale = 2
end

return Swarm
