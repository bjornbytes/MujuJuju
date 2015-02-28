local Hefty = extend(Shruju)

Hefty.name = 'Hefty'
Hefty.description = 'Muju\'s maximum health is greatly increased.'

Hefty.amount = 300

function Hefty:apply()
  local ratio = ctx.player.health / ctx.player.maxHealth
  ctx.player.maxHealth = ctx.player.maxHealth + self.amount
  ctx.player.health = ctx.player.maxHealth * ratio
end

function Hefty:remove()
  local ratio = ctx.player.health / ctx.player.maxHealth
  ctx.player.maxHealth = ctx.player.maxHealth - self.amount
  ctx.player.health = ctx.player.maxHealth * ratio
end

return Hefty
