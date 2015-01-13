local SugarRush = extend(Shruju)

SugarRush.code = 'sugarrush'
SugarRush.name = 'Sugar Rush'
SugarRush.description = 'Muju moves twice as fast for 90 seconds.'
SugarRush.duration = 90

function SugarRush:activate()
  ctx.player.walkSpeed = ctx.player.walkSpeed * 2
end

function SugarRush:deactivate()
  ctx.player.walkSpeed = ctx.player.walkSpeed / 2
end

return SugarRush
