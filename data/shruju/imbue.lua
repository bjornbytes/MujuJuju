local Imbue = extend(Shruju)

Imbue.name = 'Imbue'
Imbue.description = 'The shrine heals 20 health per second.'

function Imbue:apply()
  ctx.shrine.regen = ctx.shrine.regen + 20
end

function Imbue:remove()
  ctx.shrine.regen = ctx.shrine.regen - 20
end

return Imbue
