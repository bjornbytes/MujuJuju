local Flow = extend(Shruju)

Flow.code = 'flow'
Flow.name = 'Flow'
Flow.description = 'The cooldown for minion summoning is reduced by .5s.'

function Flow:apply()
  local p = ctx.players:get(ctx.id)
  p.flatCooldownReduction = p.flatCooldownReduction + .5

  if config.player.baseCooldown - p.flatCooldownReduction <= config.biomes[ctx.biome].player.minCooldown then
    table.each(ctx.shrujuPatches.objects, function(patch)
      patch:removeType('flow')
    end)
  end

  ctx.spells:add('arcadetext', {
    text = '.5s faster cooldown',
    x = p.x,
    y = p.y - 40
  })
end

return Flow
