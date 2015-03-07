local ShiverArmor = extend(Ability)
ShiverArmor.cooldown = 10
ShiverArmor.damage = 0
ShiverArmor.stunChance = 0

function ShiverArmor:activate()
  self.timer = love.math.random() * self.cooldown
end

function ShiverArmor:use()
  if ctx.player.dead then return end

  local level = self.unit:upgradeLevel('shiverarmor')
  local crystallize = self.unit:upgradeLevel('crystallize')
  ctx.player.buffs:add('shiverarmor', {
    timer = 3 + level,
    damage = self.damage + 15 * level,
    stunChance = crystallize > 0 and (self.stunChance + .05 + .15 * crystallize) or 0,
    stunDuration = 2,
    frostNova = self.unit:upgradeLevel('frostnova') > 0
  })
  self.timer = self.cooldown
end

return ShiverArmor
