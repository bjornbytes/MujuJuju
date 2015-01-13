local SpiritRush = extend(Shruju)

SpiritRush.code = 'spiritrush'
SpiritRush.name = 'Spirit Rush'
SpiritRush.description = 'Summon all day erry day (actually just for 90 seconds).'
SpiritRush.duration = 90
SpiritRush.rarity = 1

function SpiritRush:activate()
  ctx.player.flatCooldownReduction = p.flatCooldownReduction + 10
end

function SpiritRush:deactivate()
  ctx.player.flatCooldownReduction = p.flatCooldownReduction - 10
end

return SpiritRush
