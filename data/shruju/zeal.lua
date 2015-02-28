local Zeal = extend(Shruju)

Zeal.name = 'Zeal'
Zeal.description = 'Muju\'s ghost moves 40% faster in the juju realm.'

function Zeal:apply()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier * 1.4
end

function Zeal:remove()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier / 1.4
end

return Zeal
