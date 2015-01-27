local Imbue = {}

Imbue.name = 'Imbue'
Imbue.description = 'The shrine heals 20 health per second for 90 seconds.'

function Imbue:activate()
  ctx.shrine.regen = ctx.shrine.regen + 20
end

function Imbue:deactivate()
  ctx.shrine.regen = ctx.shrine.regen - 20
end

return Imbue
