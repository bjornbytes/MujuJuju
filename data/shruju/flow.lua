local Flow = extend(Shruju)

Flow.code = 'flow'
Flow.name = 'Flow'
Flow.description = 'The cooldown for minion summoning is reduced by .5s.'
Flow.cdr = .5

function Flow:activate()
  local p = ctx.player
  p.flatCooldownReduction = p.flatCooldownReduction + self.cdr

  ctx.shrujuPatches.flowLevel = ctx.shrujuPatches.flowLevel + 1

  if ctx.shrujuPatches.flowLevel >= ctx.shrujuPatches.maxFlowLevel then
    table.each(ctx.shrujuPatches.objects, function(patch)
      patch:removeType('flow')
    end)
  end

  ctx.spells:add('arcadetext', {
    text = self.cdr .. 's faster cooldown',
    x = p.x,
    y = p.y - 40
  })
end

return Flow
