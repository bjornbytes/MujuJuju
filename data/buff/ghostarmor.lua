local GhostArmor = extend(Buff)
GhostArmor.tags = {'dodge'}

function GhostArmor:prehurt(amount, source, kind)
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  local chance = .1 * self.unit:upgradeLevel('ghostarmor')
  if kind and table.has(kind, 'attack') and (ctx.player.dead or hasBastion) and love.math.random() < chance then
    return 0
  end

  return amount
end

return GhostArmor
