local Zeal = extend(Shruju)

Zeal.name = 'Zeal'
Zeal.description = 'Muju moves 20% faster in the juju realm for 90 seconds.'

function Zeal:apply()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier * 1.2
end

function Zeal:remove()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier / 1.2
end

return Zeal
