local Wealth = extend(Shruju)

Wealth.name = 'Wealth'
Wealth.description = 'Doubles your passive juju income for 90 seconds.'
Wealth.duration = 90
Wealth.rarity = 1

function Wealth:activate()
  ctx.player.jujuRate = ctx.player.jujuRate / 2
end

function Wealth:deactivate()
  ctx.player.jujuRate = ctx.player.jujuRate * 2
end

return Wealth
