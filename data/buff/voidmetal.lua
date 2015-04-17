local VoidMetal = extend(Buff)
VoidMetal.tags = {}

VoidMetal.runeChance = 0

function VoidMetal:shouldApplyBuff(code)
  local level = self.unit:upgradeLevel('voidmetal')
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  local chance = (hasBastion and ctx.player.dead) and 1 or self.runeChance + .4
  if self.unit.buffs:isCrowdControl(code) then
    return love.math.random() > chance
  end

  return true
end

function VoidMetal:bonuses()
  local bonuses = {}
  if self.runeChance > 0 then
    table.insert(bonuses, {'Runes', lume.round(self.runeChance * 100) .. '%', 'chance'})
  end
  return bonuses
end

return VoidMetal
