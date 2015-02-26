local Wealth = extend(Shruju)

Wealth.name = 'Wealth'
Wealth.description = 'Increases Muju\'s passive juju income by 30%'

function Wealth:apply()
  ctx.player.jujuRate = ctx.player.jujuRate * .7
end

function Wealth:remove()
  ctx.player.jujuRate = ctx.player.jujuRate / .7
end

return Wealth
