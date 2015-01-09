Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)
  self.level = 0
  self.nextEnemy = 5
  table.merge(config.biomes[ctx.biome].units, self)
end

function Units:createEnemy()
  local conf = config.biomes[ctx.biome]
  if self.enemyCount < 1 + math.floor(self.level * conf.units.maxEnemiesCoefficient) then
    local choices = {}
    table.each(conf.units.thresholds, function(time, code)
      if ctx.timer * tickRate >= time then table.insert(choices, code) end
    end)
    local enemyType = choices[love.math.random(1, #choices)]
    local x = love.math.random() < .5 and Unit.width / 2 or ctx.map.width - Unit.width / 2
    local eliteChance = config.elites.baseModifier + (config.elites.levelModifier * self.level)
    local eliteCount = table.count(self:filter(function(u) return u.elite end))
    local isElite = love.math.random() < eliteChance
    isElite = isElite and self.level > config.elites.minimumLevel
    isElite = isElite and eliteCount < conf.units.maxElites
    local unit = self:add(enemyType, {x = x, elite = isElite})

    if isElite then
      local buffs = table.keys(config.elites.buffs)
      local buff = buffs[love.math.random(1, #buffs)]
      unit.buffs:add(buff, config.elites.buffs[buff])
    end

    self.minEnemyRate = math.max(self.minEnemyRate - conf.units.minEnemyRateDecay * math.clamp((1.5 + self.minEnemyRate) / 6, .2, 1), 1.5)
    self.maxEnemyRate = math.max(self.maxEnemyRate - conf.units.maxEnemyRateDecay * math.clamp((3.0 + self.maxEnemyRate) / 6, .4, 1), 3.0)
  else
    return .5
  end

  return self.minEnemyRate + love.math.random() * (self.maxEnemyRate - self.minEnemyRate)
end

function Units:update()
  self.enemyCount = table.count(self:filter(function(u) return u.team == 0 end))
  self.nextEnemy = timer.rot(self.nextEnemy, f.cur(self.createEnemy, self))

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
