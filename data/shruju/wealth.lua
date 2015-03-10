local Wealth = extend(Shruju)

Wealth.name = 'Wealth'
Wealth.description = 'Increases Muju\'s passive juju income rate by 50%'

function Wealth:apply()
  ctx.player.jujuRate = ctx.player.jujuRate / 1.5
end

function Wealth:remove()
  ctx.player.jujuRate = ctx.player.jujuRate * 1.5
end

return Wealth
