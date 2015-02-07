UnitBuffs = class()

function UnitBuffs:init(unit)
  self.unit = unit
  self.list = {}

  table.merge(table.only(self.unit.class, Unit.classStats), self.unit)
  self:applyRunes('health')
  self:applyRunes('damage')
  self:applyRunes('spirit')
  self:applyRunes('haste')
end

function UnitBuffs:preupdate()
  table.with(self.list, 'preupdate')
end

function UnitBuffs:postupdate()
  table.with(self.list, 'rot')
  table.with(self.list, 'postupdate')
  table.with(self.list, 'update')

  self.unit.speed = self:getBaseSpeed()

  local speed = self.unit.speed

  -- Apply Hastes
  local hastes = self:buffsWithTag('haste')
  table.each(hastes, function(haste)
    speed = speed + (self.unit.class.speed * haste.haste)
  end)

  -- Apply Slows
  local slows = self:buffsWithTag('slow')
  table.each(slows, function(slow)
    speed = speed * (1 - slow.slow)
  end)

  if self:feared() then speed = speed / 2 end

  self.unit.speed = speed

  -- Apply Roots and Stuns
  if self:rooted() or self:stunned() then self.unit.speed = 0 end

  -- Apply Attack Speed Increases
  local attackSpeed = self:getBaseAttackSpeed()
  local frenzies = self:buffsWithTag('frenzy')
  table.each(frenzies, function(frenzy)
    attackSpeed = attackSpeed * (1 - frenzy.frenzy)
  end)

  -- Apply Attack Speed Decreases
  local exhausts = self:buffsWithTag('exhaust')
  table.each(exhausts, function(exhaust)
    attackSpeed = attackSpeed + attackSpeed * (1 - exhaust.exhaust)
  end)

  self.unit.attackSpeed = math.max(attackSpeed, .4)

  -- Apply DoTs
  local dots = self:buffsWithTag('dot')
  table.each(dots, function(dot)
    self.unit:hurt(dot.dot * tickRate)
  end)

  -- Apply Knockups
  self.unit.prev.knockup = self.unit.knockup
  self.unit.knockup = 0
  local knockups = self:buffsWithTag('knockup')
  table.each(knockups, function(knockup)
    self.unit.knockup = self.unit.knockup + knockup.knockup
  end)
end

function UnitBuffs:add(code, vars)
  if self:isCrowdControl(code) and self:ccImmunity() == 1 then return end
  if self:get(code) then return self:reapply(code, vars) end
  local buff = data.buff[code]()
  buff.unit = self.unit
  self.list[buff] = buff
  table.merge(vars, buff, true)
  if buff.stack then buff.stacks = 1 end
  f.exe(buff.activate, buff)
  return buff
end

function UnitBuffs:remove(buff)
  if type(buff) == 'string' then
    buff = self:get(buff)
  end

  if buff then
    f.exe(buff and buff.deactivate, buff, self.unit)
    self.list[buff] = nil
  end
end

function UnitBuffs:get(code)
  return next(table.filter(self.list, function(buff) return buff.code == code end))
end

function UnitBuffs:reapply(code, vars)
  if self:isCrowdControl(code) and self:ccImmunity() == 1 then return end
  local buff = self:get(code)
  if buff then
    table.merge(vars, buff, true)
    if buff.stacks then
      buff.stacks = math.min((buff.stacks or 1) + 1, buff.maxStacks or 1)
    end
    return buff
  else
    return self:add(code, vars)
  end
end

function UnitBuffs:buffsWithTag(tag)
  return table.filter(self.list, function(buff) return table.has(buff.tags, tag) end)
end

function UnitBuffs:isCrowdControl(buff)
  if type(buff) == 'string' then buff = data.buff[buff] end
  local tags = buff.tags
  local function t(s) return table.has(tags, s) end
  return t('slow') or t('root') or t('stun') or t('silence') or t('knockback') or t('taunt')
end

function UnitBuffs:applyRunes(stat)
  if not self.unit.player or not self.unit:hasRunes() then return end

  local runes = self.unit.player.deck[self.unit.class.code].runes
  table.each(runes, function(rune)
    if rune.stats and rune.stats[stat] then
      self.unit[stat] = self.unit[stat] + rune.stats[stat]
    end
  end)
end

function UnitBuffs:getBaseSpeed()
  local speed = self.unit.class.speed
  if not self.unit.player then return speed end

  local agilityLevel = self.unit.class.attributes.agility
  speed = speed + agilityLevel * config.attributes.agility.speed

  local runes = self.unit.player.deck[self.unit.class.code].runes
  table.each(runes, function(rune)
    if rune.stats and rune.stats.speed then
      speed = speed + rune.stats.speed
    end
  end)

  return speed
end

function UnitBuffs:getBaseAttackSpeed()
  local baseSpeed = self.unit.class.attackSpeed
  local speed = baseSpeed
  if not self.unit.player then return speed end

  local agilityLevel = self.unit.class.attributes.agility
  speed = speed - (agilityLevel * config.attributes.agility.attackSpeed) * baseSpeed

  local runes = self.unit.player.deck[self.unit.class.code].runes
  table.each(runes, function(rune)
    if rune.stats and rune.stats.attackSpeed then
      speed = speed - (rune.stats.attackSpeed * baseSpeed)
    end
  end)

  return math.max(speed, .4)
end

function UnitBuffs:prehurt(amount, source, kind)
  table.with(self.list, 'prehurt', amount, source, kind)

  if kind and table.has(kind, 'attack') then
    local armors = self:buffsWithTag('armor')
    local armor = 0
    table.each(armors, function(buff)
      armor = armor + (1 - armor) * math.clamp(buff.armor * (buff.armorRangedMultiplier or 1), 0, .9)
    end)

    amount = amount * (1 - armor)
  end

  return amount
end

function UnitBuffs:posthurt(amount, source, kind)
  table.with(self.list, 'posthurt', amount, source, kind)

  return amount
end

function UnitBuffs:preattack(target, damage)
  table.each(self.list, function(buff)
    if buff.preattack then
      damage = buff:preattack(target, damage) or damage
    end
  end)

  return damage
end

function UnitBuffs:postattack(target, damage)
  table.with(self.list, 'postattack', target, damage)
end

function UnitBuffs:slowed()
  return next(self:buffsWithTag('slow'))
end

function UnitBuffs:taunted()
  local taunt = next(self:buffsWithTag('taunt'))
  return taunt and taunt.target
end

function UnitBuffs:stunned()
  return next(self:buffsWithTag('stun'))
end

function UnitBuffs:rooted()
  return next(self:buffsWithTag('root'))
end

function UnitBuffs:silenced()
  return next(self:buffsWithTag('silence'))
end

function UnitBuffs:ccImmunity()
  local vulnerability = 1
  table.each(self:buffsWithTag('ccimmune'), function(buff)
    vulnerability = vulnerability * (1 - buff.ccimmunity)
  end)
  return 1 - vulnerability
end

function UnitBuffs:feared()
  local fear = next(self:buffsWithTag('fear'))
  return fear and fear.target
end

function UnitBuffs:potency()
  local ratio = 1
  table.each(self:buffsWithTag('potency'), function(potency)
    ratio = ratio * potency
  end)
  return ratio
end
