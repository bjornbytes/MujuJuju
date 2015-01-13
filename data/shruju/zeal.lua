local Zeal = extend(Shruju)

Zeal.code = 'zeal'
Zeal.name = 'Zeal'
Zeal.description = 'Muju moves twice as fast in the juju realm for 90 seconds.'
Zeal.duration = 90
Zeal.rarity = 1

function Zeal:activate()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier * 2
end

function Zeal:deactivate()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier / 2
end

return Zeal
