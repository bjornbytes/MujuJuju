local Harvest = extend(Shruju)

Harvest.code = 'harvest'
Harvest.name = 'Harvest'
Harvest.description = 'Permanently causes all shruju to grow 6 seconds faster.'

Harvest.time = 60

function Harvest:apply()
  ctx.shrujuPatches.harvestLevel = ctx.shrujuPatches.harvestLevel + 1
end

return Harvest
