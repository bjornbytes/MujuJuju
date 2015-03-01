local VoidMetal = extend(Buff)
VoidMetal.tags = {}

function VoidMetal:shouldApplyBuff(code)
  local level = self.unit:upgradeLevel('voidmetal')
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  local chance = level == 1 and .4 or .6
  if self.unit.buffs:isCrowdControl(code) and (ctx.player.dead or hasBastion) then
    return love.math.random() > chance
  end

  return true
end

return VoidMetal
