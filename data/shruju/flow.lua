local Flow = class()

Flow.code = 'flow'
Flow.name = 'Flow'
Flow.description = 'The cooldown for minion summing is reduced by .25s.'

Flow.time = 60

function Flow:eat()
  local p = ctx.players:get(ctx.id)
  p.flatCooldownReduction = p.flatCooldownReduction + .25
end

return Flow
