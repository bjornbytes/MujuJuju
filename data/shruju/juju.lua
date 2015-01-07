local Juju = extend(Shruju)

Juju.code = 'juju'
Juju.name = 'Juju'
Juju.description = 'On use, gives 50 juju.'

function Juju:apply()
  local p = ctx.players:get(ctx.id)
  local amount = 50
  p.juju = p.juju + amount
  ctx.hud.status.jujuScale = 2
  ctx.hud.status.jujuAngle = 0
  ctx.spells:add('arcadetext', {
    text = '+50 juju',
    x = p.x,
    y = p.y - 40
  })
end

return Juju
