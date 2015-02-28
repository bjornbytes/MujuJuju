local Zeal = extend(Shruju)

Zeal.name = 'Zeal'
Zeal.description = 'Muju\'s ghost moves 70% faster in the juju realm.'

function Zeal:apply()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier * 1.7
end

function Zeal:remove()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier / 1.7
end

return Zeal
