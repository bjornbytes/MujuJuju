local SpiritRush = extend(Shruju)

SpiritRush.name = 'Spirit Rush'
SpiritRush.description = 'Muju channels spiritual energy, resulting in halved cooldown times.'

function SpiritRush:apply()
  ctx.player.cooldownSpeed = ctx.player.cooldownSpeed * 2
end

function SpiritRush:remove()
  ctx.player.cooldownSpeed = ctx.player.cooldownSpeed / 2
end

return SpiritRush
