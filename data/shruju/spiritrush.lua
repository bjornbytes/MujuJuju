local SpiritRush = extend(Shruju)

SpiritRush.name = 'Spirit Rush'
SpiritRush.description = 'Summon all day erry day (actually just for 90 seconds).'

function SpiritRush:apply()
  ctx.player.cooldownSpeed = ctx.player.cooldownSpeed + 1
end

function SpiritRush:remove()
  ctx.player.cooldownSpeed = ctx.player.cooldownSpeed - 1
end

return SpiritRush
