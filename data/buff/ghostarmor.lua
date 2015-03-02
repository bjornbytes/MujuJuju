local GhostArmor = extend(Buff)
GhostArmor.tags = {'dodge'}

function GhostArmor:prehurt(amount, source, kind)
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  local chance = (hasBastion and ctx.player.dead) and 1 or (.05 + .05 * self.unit:upgradeLevel('ghostarmor'))
  if kind and table.has(kind, 'attack') and love.math.random() < chance then
    return 0
  end

  return amount
end

return GhostArmor
