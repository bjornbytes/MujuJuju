local GhostArmor = extend(Buff)
GhostArmor.tags = {}

function GhostArmor:shouldApplyBuff(code)
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  if self.unit.buffs:isCrowdControl(code) and (ctx.player.dead or hasBastion) then
    return love.math.random() > self.unit:upgradeLevel('ghostarmor') / 5
  end

  return true
end

return GhostArmor
