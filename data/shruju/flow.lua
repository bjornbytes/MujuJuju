local Flow = extend(Shruju)

Flow.code = 'flow'
Flow.name = 'Flow'
Flow.description = 'The cooldown for minion summing is reduced by .25s.'

function Flow:apply()
  local p = ctx.players:get(ctx.id)
  p.flatCooldownReduction = p.flatCooldownReduction + .25

  if config.player.baseCooldown - p.flatCooldownReduction <= config.player.minCooldown then
    table.each(ctx.shrujuPatches.objects, function(patch)
      patch:removeType('flow')
    end)
  end

  ctx.spells:add('arcadetext', {
    text = '.25s faster cooldown',
    x = p.x,
    y = p.y - 40
  })
end

return Flow
