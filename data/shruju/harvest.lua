local Harvest = extend(Shruju)

Harvest.code = 'harvest'
Harvest.name = 'Harvest'
Harvest.description = 'Permanently causes all shruju to grow 6 seconds faster.'

function Harvest:apply()
  ctx.shrujuPatches.harvestLevel = ctx.shrujuPatches.harvestLevel + 1

  if config.shruju.growTime - (ctx.shrujuPatches.harvestLevel * config.shruju.harvestCooldownReduction) <= config.shruju.minGrowTime then
    table.each(ctx.shrujuPatches.objects, function(patch)
      patch:removeType('harvest')
    end)
  end
end

return Harvest
