local Juju = extend(Shruju)

Juju.code = 'juju'
Juju.name = 'Juju'
Juju.description = 'On use, gives 25 juju (+5 per minute).'

function Juju:apply()
  local p = ctx.players:get(ctx.id)
  local amount = 25 + 5 * math.floor(ctx.timer * tickRate / 60)
  p.juju = p.juju + amount
  ctx.hud.status.jujuScale = 2
  ctx.hud.status.jujuAngle = 0
  ctx.spells:add('arcadetext', {
    text = '+' .. amount .. ' juju',
    x = p.x,
    y = p.y - 40
  })
end

return Juju
