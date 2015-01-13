local Renew = extend(Shruju)

Renew.code = 'renew'
Renew.name = 'Renew'
Renew.description = 'On use, heals your shrine for 10% of its maximum health'

function Renew:activate()
  local p = ctx.player
  local _, shrine = next(ctx.shrines:filter(function(s) return s.team == p.team end))
  if shrine then
    shrine.health = math.min(shrine.health + shrine.maxHealth * .1, shrine.maxHealth)
  end

  ctx.spells:add('arcadetext', {
    text = 'shrine healed',
    x = p.x,
    y = p.y - 40
  })
end

return Renew
