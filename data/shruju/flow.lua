local Flow = extend(Shruju)

Flow.name = 'Flow'
Flow.description = 'Summon recharge rate increased by 10%'
Flow.cdr = .1

function Flow:activate()
  local p = ctx.player
  p.cooldownSpeed = p.cooldownSpeed + self.cdr

  ctx.spells:add('arcadetext', {
    text = (self.cdr * 100) .. '% faster cooldown',
    x = p.x,
    y = p.y - 40
  })
end

return Flow
