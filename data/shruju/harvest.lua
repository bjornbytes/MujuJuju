local Harvest = class()

Harvest.code = 'harvest'
Harvest.name = 'Harvest'
Harvest.description = 'Permanently causes all shruju to grow 3 seconds faster.'

Harvest.time = 60

function Harvest:eat()
  ctx.shrujuPatches.harvestLevel = ctx.shrujuPatches.harvestLevel + 1
end

return Harvest
