local Imbue = extend(Shruju)

Imbue.code = 'imbue'
Imbue.name = 'Imbue'
Imbue.description = 'The shrine heals 20 health per second for 90 seconds.'
Imbue.duration = 90
Imbue.rarity = 1

function Imbue:activate()
  ctx.shrine.regen = ctx.shrine.regen + 20
end

function Imbue:deactivate()
  ctx.shrine.regen = ctx.shrine.regen - 20
end

return Imbue
