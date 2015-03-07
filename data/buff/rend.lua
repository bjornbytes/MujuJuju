local Rend = extend(Buff)
Rend.tags = {'crit'}

Rend.runeChance = 0
Rend.runePerStack = 0

function Rend:preattack(target, amount)
  local level = self.unit:upgradeLevel('rend')
  local chances = {.08, .15, .21, .26, .30}
  local chance = self.runeChance + chances[level]
  local deathwishLevel = self.unit:upgradeLevel('deathwish')

  if deathwishLevel > 0 and target.health / target.maxHealth < .2 + .1 * deathwishLevel then
    chance = chance * 2
  end

  if love.math.random() < chance then
    local furyLevel = self.unit:upgradeLevel('fury')
    if furyLevel > 0 then
      local buff = self.unit.buffs:get('fury')
      local amount = self.runePerStack + ({.1, .12, .15})[furyLevel]
      if buff then buff.maxStacks = 2 + furyLevel end
      buff = self.unit.buffs:add('fury', {timer = 5})
      buff.frenzy = buff.stack and amount * buff.stacks or amount
    end

    local x, y = self.unit:attackParticlePosition(target)
    ctx.particles:emit('crit', x, y, 10)

    return amount * 2
  end

  return amount
end

return Rend
