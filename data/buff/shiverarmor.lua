local ShiverArmor = extend(Buff)
ShiverArmor.tags = {}

function ShiverArmor:prehurt(amount, source, kind)
  if source and kind and table.has(kind, 'attack') then
    source:hurt(self.damage, self.player)

    if source.buffs and love.math.random() < self.stunChance then
      source.buffs:add('crystallize', {timer = self.stunDuration})
    end
  end
end

function ShiverArmor:update()
  if love.math.random() < .8 then
    ctx.particles:emit('kujuattack', self.player.x, self.player.y + self.player.height / 2, 1)
  end
end

function ShiverArmor:die()
  if self.frostNova then
    local targets = ctx.target:inRange(ctx.player, 180, 'enemy', 'unit')
    table.each(targets, function(target)
      target:hurt(self.damage, self.player)
      ctx.particles:emit('frozenorb', target.x, target.y, 1)

      if target.buffs and love.math.random() < self.stunChance then
        target.buffs:add('crystallize', {timer = self.stunDuration})
      end
    end)

    self.player.buffs:remove(self)
  end
end

return ShiverArmor
