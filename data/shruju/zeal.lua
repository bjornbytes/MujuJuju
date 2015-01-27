local Zeal = {}

Zeal.name = 'Zeal'
Zeal.description = 'Muju moves twice as fast in the juju realm for 90 seconds.'

function Zeal:activate()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier * 2
end

function Zeal:deactivate()
  ctx.player.ghostSpeedMultiplier = ctx.player.ghostSpeedMultiplier / 2
end

return Zeal
