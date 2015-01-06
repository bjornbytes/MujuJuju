local Flow = extend(Shruju)

Flow.code = 'flow'
Flow.name = 'Flow'
Flow.description = 'The cooldown for minion summing is reduced by .25s.'

function Flow:apply()
  local p = ctx.players:get(ctx.id)
  p.flatCooldownReduction = p.flatCooldownReduction + .25

  if config.player.baseCooldown - p.flatCooldownReduction <= config.player.minCooldown then
    ctx.shrujuPatches:each(function(flow)
      patch:removeType('flow')
    end)
  end
end

return Flow
