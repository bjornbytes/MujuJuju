local GhostArmor = extend(Buff)
GhostArmor.tags = {'dodge'}

GhostArmor.runeChance = 0

function GhostArmor:prehurt(amount, source, kind)
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  local chance = (hasBastion and ctx.player.dead) and 1 or (self.runeChance + .05 + .05 * self.unit:upgradeLevel('ghostarmor'))
  if kind and table.has(kind, 'attack') and love.math.random() < chance then
    return 0
  end

  return amount
end

function GhostArmor:bonuses()
  local bonuses = {}
  if self.runeChance > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeChance * 100) .. '%', 'dodge chance'})
  end
  return bonuses
end

return GhostArmor
