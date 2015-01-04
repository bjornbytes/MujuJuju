Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)
  self.level = 0
  self.nextEnemy = 5
  table.merge(config.units[ctx.biome], self)
end

function Units:update()
  local enemyCount = table.count(self:filter(function(u) return u.team == 0 end))

  self.nextEnemy = timer.rot(self.nextEnemy, function()
    if enemyCount < 1 + self.level / 2 then
      local enemyType = 'duju'
      local x = love.math.random() < .5 and 0 or ctx.map.width

      self:add(enemyType, {x = x})
      self.minEnemyRate = math.max(self.minEnemyRate - .055 * math.clamp(self.minEnemyRate / 5, .1, 1), 1.4)
      self.maxEnemyRate = math.max(self.maxEnemyRate - .03 * math.clamp(self.maxEnemyRate / 4, .5, 1), 2.75)
    end
    return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
  end)

  if enemyCount == 0 and self.level > 1 then
    self.nextEnemy = math.max(.01, math.lerp(self.nextEnemy, 0, .75 * tickRate))
  end

  self.level = self.level + (tickRate / (16 + self.level / 2)) * config.units[ctx.biome].levelScale

  return Manager.update(self)
end

function Units:add(class, vars)
  local unit = Unit()
  table.merge(vars, unit, true)
  unit.class = data.unit[class]
  f.exe(unit.activate, unit)
  self.objects[unit] = unit

  return unit
end

function Units:remove(unit)
  f.exe(unit.deactivate, unit)
  self.objects[unit] = nil
end
