local ShiverArmor = extend(Ability)
ShiverArmor.runeDamage = 0
ShiverArmor.runeStunChance = 0
ShiverArmor.spiritRatio = .4

function ShiverArmor:update()
  if not ctx.player.buffs:get('shiverarmor') then
    ctx.player.buffs:add('shiverarmor', {stunDuration = 2})
  end
end

function ShiverArmor:bonuses()
  local bonuses = {}

  local spirit = Unit.getStat('kuju', 'spirit')
  if spirit > 0 then
    table.insert(bonuses, {'Spirit', lume.round(spirit * self.spiritRatio), 'damage'})
  end

  if self.runeDamage > 0 then
    table.insert(bonuses, {'Runes', lume.round(self.runeDamage), 'damage'})
  end

  return bonuses
end

return ShiverArmor
