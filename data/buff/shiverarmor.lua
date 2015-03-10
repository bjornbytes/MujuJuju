local ShiverArmor = extend(Buff)
ShiverArmor.tags = {}

function ShiverArmor:prehurt(amount, source, kind)
  if source and kind and table.has(kind, 'attack') then
    local damage = self:getDamage()
    local stunChance = self:getStunChance()
    source:hurt(damage, self.player)

    if source.buffs and love.math.random() < stunChance then
      source.buffs:add('crystallize', {timer = self.stunDuration})
    end
  end
end

function ShiverArmor:update()
  if love.math.random() < .2 and not ctx.player.dead then
    ctx.particles:emit('kujuattack', self.player.x, self.player.y + self.player.height / 2 + love.math.randomNormal(15), 1)
  end
end

function ShiverArmor:die()
  if data.unit.kuju.upgrades.frostnova.level > 0 then
    local targets = ctx.target:inRange(ctx.player, 180, 'enemy', 'unit')
    table.each(targets, function(target)
      local damage = self:getDamage()
      local stunChance = self:getStunChance()
      target:hurt(damage, self.player)
      ctx.particles:emit('frozenorb', target.x, target.y, 1)

      if target.buffs and love.math.random() < stunChance then
        target.buffs:add('crystallize', {timer = self.stunDuration})
      end
    end)
  end
end

function ShiverArmor:getDamage()
  local ability = data.ability.kuju.shiverarmor
  local level = data.unit.kuju.upgrades.shiverarmor.level
  local spirit = Unit.getStat('kuju', 'spirit')
  return ability.runeDamage + 15 * level + ability.spiritRatio * spirit
end

function ShiverArmor:getStunChance()
  local ability = data.ability.kuju.shiverarmor
  local level = data.unit.kuju.upgrades.crystallize.level
  return level > 0 and (ability.runeStunChance + .05 + .15 * level) or 0
end

return ShiverArmor
