local Rally = extend(Shruju)

Rally.code = 'rally'
Rally.name = 'Rally'
Rally.description = 'On use, increases the maximum number of minions you can have summoned at a time by 1.'

function Rally:apply()
 local p = ctx.player
 p.maxPopulation = p.maxPopulation + 1
 ctx.hud.status.populationScale = 2

 if p.maxPopulation >= config.biomes[ctx.biome].player.maxPopulation then
    table.each(ctx.shrujuPatches.objects, function(patch)
      patch:removeType('rally')
    end)
 end

  ctx.spells:add('arcadetext', {
    text = '+1 population',
    x = p.x,
    y = p.y - 40
  })
end

return Rally
