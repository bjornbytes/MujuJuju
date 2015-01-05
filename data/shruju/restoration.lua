local Restoration = class()

Restoration.code = 'restoration'
Restoration.name = 'Restoration'
Restoration.description = 'On use, heals your shrine for 10% of its maximum health'

Restoration.time = 60

function Restoration:eat()
  local p = ctx.players:get(ctx.id)
  local _, shrine = next(ctx.shrines:filter(function(s) return s.team == p.team end))
  if shrine then
    shrine.health = math.min(shrine.health + shrine.maxHealth * .1, shrine.maxHealth)
  end
end

return Restoration
