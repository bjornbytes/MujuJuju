local ShiverArmor = extend(Ability)
ShiverArmor.cooldown = 10
ShiverArmor.runeDamage = 0
ShiverArmor.runeStunChance = 0

function ShiverArmor:activate()
  self.timer = love.math.random() * self.cooldown
end

function ShiverArmor:use()
  if ctx.player.dead then return end

  local level = self.unit:upgradeLevel('shiverarmor')
  local crystallize = self.unit:upgradeLevel('crystallize')
  ctx.player.buffs:add('shiverarmor', {
    timer = 3 + level,
    damage = self.runeDamage + 15 * level,
    stunChance = crystallize > 0 and (self.runeStunChance + .05 + .15 * crystallize) or 0,
    stunDuration = 2,
    frostNova = self.unit:upgradeLevel('frostnova') > 0
  })
  self.timer = self.cooldown
end

function ShiverArmor:bonuses()
  local bonuses = {}

  if self.runeDamage > 0 then
    table.insert(bonuses, {'Runes', self.runeDamage, 'damage'})
  end

  return bonuses
end

return ShiverArmor
