local Imbue = extend(Shruju)

Imbue.name = 'Imbue'
Imbue.description = 'The shrine heals 0.5% of its maximum health every second.'

function Imbue:apply()
  ctx.shrine.regen = ctx.shrine.regen + 25
end

function Imbue:remove()
  ctx.shrine.regen = ctx.shrine.regen - 25
end

return Imbue
