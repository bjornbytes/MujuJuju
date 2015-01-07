local Rally = extend(Shruju)

Rally.code = 'rally'
Rally.name = 'Rally'
Rally.description = 'On use, increases the maximum number of minions you can have summoned at a time by 1.'

function Rally:apply()
 local p = ctx.players:get(ctx.id)
 p.maxPopulation = p.maxPopulation + 1
 ctx.hud.status.populationScale = 2

 if p.maxPopulation >= config.player.maxPopulation then
    table.each(ctx.shrujuPatches.objects, function(patch)
      patch:removeType('rally')
    end)
 end
end

return Rally