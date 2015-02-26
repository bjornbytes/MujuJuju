local Wealth = extend(Shruju)

Wealth.name = 'Wealth'
Wealth.description = 'Doubles your passive juju income for 90 seconds.'

function Wealth:apply()
  ctx.player.jujuRate = ctx.player.jujuRate / 2
end

function Wealth:remove()
  ctx.player.jujuRate = ctx.player.jujuRate * 2
end

return Wealth
