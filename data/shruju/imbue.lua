local Imbue = extend(Shruju)

Imbue.name = 'Imbue'
Imbue.description = 'The shrine heals .4% of its maximum health every second.'

function Imbue:apply()
  ctx.shrine.regen = ctx.shrine.regen + (ctx.shrine.maxHealth * .004)
end

function Imbue:remove()
  ctx.shrine.regen = ctx.shrine.regen - (ctx.shrine.maxHealth * .004)
end

return Imbue
