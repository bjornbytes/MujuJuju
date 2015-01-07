Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)
  self.level = 0
  self.nextEnemy = 5
  table.merge(config.biomes[ctx.biome].units, self)
end

function Units:createEnemy()
  if self.enemyCount < 1 + self.level * config.biomes[ctx.biome].units.maxEnemiesCoefficient then
    local choices = {}
    table.each(config.biomes[ctx.biome].units.thresholds, function(time, code)
      if ctx.timer * tickRate >= time then table.insert(choices, code) end
    end)
    local enemyType = choices[love.math.random(1, #choices)]
    local x = love.math.random() < .5 and Unit.width / 2 or ctx.map.width - Unit.width / 2
    local eliteChance = config.elites.baseModifier + (config.elites.levelModifier * self.level)
    local eliteCount = table.count(self:filter(function(u) return u.elite end))
    local isElite = love.math.random() < eliteChance
    isElite = isElite and self.level > config.elites.minimumLevel
    isElite = isElite and eliteCount < config.biomes[ctx.biome].units.maxElites
    local unit = self:add(enemyType, {x = x, elite = isElite})

    if isElite then
      local buffs = table.keys(config.elites.buffs)
      local buff = buffs[love.math.random(1, #buffs)]
      unit.buffs:add(buff, config.elites.buffs[buff])
    end

    self.minEnemyRate = math.max(self.minEnemyRate - .055 * math.clamp(self.minEnemyRate / 5, .1, .6), 1.4)
    self.maxEnemyRate = math.max(self.maxEnemyRate - .03 * math.clamp(self.maxEnemyRate / 4, .2, .8), 2.75)
  end

  return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
end

function Units:update()
  self.enemyCount = table.count(self:filter(function(u) return u.team == 0 end))
  self.nextEnemy = timer.rot(self.nextEnemy, f.cur(self.createEnemy, self))

  if self.enemyCount == 0 and self.level > 1 then
    self.nextEnemy = math.max(.01, math.lerp(self.nextEnemy, 0, .75 * tickRate))
  end

  self.level = self.level + (tickRate / (16 + self.level / 2)) * config.biomes[ctx.biome].units.levelScale

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
  unit = nil
end
