Units = extend(Manager)
Units.manages = 'unit'

function Units:init()
  Manager.init(self)

  self.config = ctx.mode == 'campaign' and config.enemies[ctx.biome] or config.enemies.survival
  self.level = 0
  self.nextEnemy = 5
  self.enemyCount = 0
  self.nextSpike = 10 * 60 / ls.tickrate
  table.merge(self.config, self)
end

function Units:createEnemy()
  local conf = config.biomes[ctx.biome]
  if self.enemyCount < 2 + math.floor(self.level * self.maxEnemiesCoefficient) then
    local choices = {}
    table.each(self.types, function(time, code)
      if ctx.timer * ls.tickrate >= time then table.insert(choices, code) end
    end)
    local enemyType = choices[love.math.random(1, #choices)]
    local x = love.math.random() < .5 and Unit.width / 2 or ctx.map.width - Unit.width / 2
    local eliteChance = config.elites.baseModifier + (config.elites.levelModifier * self.level)
    local eliteCount = table.count(self:filter(function(u) return u.elite end))
    local isElite = love.math.random() < eliteChance
    isElite = isElite and self.level > self.eliteLevelThreshold
    isElite = isElite and eliteCount < self.maxElites
    local unit = self:add(enemyType, {x = x, elite = isElite})

    if isElite then
      local buffs = table.keys(config.elites.buffs)
      for i = 1, math.min(self.maxEliteBuffCount, math.max(1, math.floor(ctx.timer * ls.tickrate / 60 / 5))) do
        local index = love.math.random(1, #buffs)
        local buff = buffs[index]
        table.remove(buffs, index)
        unit.buffs:add(buff, config.elites.buffs[buff])
      end
    end

    self.minEnemyRate = math.max(self.minEnemyRate - self.minEnemyRateDecay * math.clamp((0.2 + self.minEnemyRate) / 10, .2, 1), 0.2)
    self.maxEnemyRate = math.max(self.maxEnemyRate - self.maxEnemyRateDecay * math.clamp((0.2 + self.maxEnemyRate) / 10, .4, 1), 0.2)
    if self.maxEnemyRate < self.minEnemyRate then self.maxEnemyRate = self.minEnemyRate end
  else
    return .5
  end

  return math.max(love.math.randomNormal(self.maxEnemyRate - self.minEnemyRate, (self.minEnemyRate + self.maxEnemyRate) / 2), ls.tickrate)
end

function Units:update()
  if not ctx.tutorial.active then
    self.enemyCount = table.count(self:filter(function(u) return u.team == 0 end))
    self.nextEnemy = timer.rot(self.nextEnemy, f.cur(self.createEnemy, self))

    self.level = self.level + (ls.tickrate / 15) * self.levelScale

    if tick > self.nextSpike then
      self.levelScale = self.levelScale * 3
      self.nextSpike = self.nextSpike + (10 * 60 / ls.tickrate)
    end
  end

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

function Units:clear()
  table.each(self.objects, function(unit)
    self:remove(unit)
  end)
  self:init()
end
