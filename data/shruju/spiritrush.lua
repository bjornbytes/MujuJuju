local SpiritRush = extend(Shruju)

SpiritRush.name = 'Spirit Rush'
SpiritRush.description = 'Summon all day erry day (actually just for 90 seconds).'
SpiritRush.duration = 90
SpiritRush.rarity = 1

function SpiritRush:activate()
  ctx.player.cooldownSpeed = ctx.player.cooldownSpeed + 1
end

function SpiritRush:deactivate()
  ctx.player.cooldownSpeed = ctx.player.cooldownSpeed - 1
end

return SpiritRush
