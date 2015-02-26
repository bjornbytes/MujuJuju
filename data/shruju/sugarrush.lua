local SugarRush = extend(Shruju)

SugarRush.name = 'Sugar Rush'
SugarRush.description = 'Muju moves twice as fast.'

function SugarRush:apply()
  ctx.player.walkSpeed = ctx.player.walkSpeed * 2
end

function SugarRush:remove()
  ctx.player.walkSpeed = ctx.player.walkSpeed / 2
end

return SugarRush
