UnitAI = class()

function UnitAI:update()
  if not self.unit.player then self:changeTarget(ctx.target:closest(self.unit, 'enemy', 'shrine', 'player', 'unit')) end

  local target = self.unit.attackTarget
  if target and target.untargetable then
    self.unit.attackTarget = nil
    target = nil
    self.unit.animation:set('idle')
  end

  if target then
    if self:inRange(target) then
      self:startAttacking(target)
    else
      self:moveIntoRange(target)
    end
  else
    self:moveTowards(self.unit.moveTarget)
  end
end

function UnitAI:changeTarget(target)
  local taunt = self.unit.buffs:taunted()
  self.unit.attackTarget = taunt or target
end

function UnitAI:inRange(target)
  return math.abs(target.x - self.unit.x) <= self.unit.range + target.width / 2 + self.unit.width / 2
end

function UnitAI:moveIntoRange(target)
  local feared = self.unit.buffs:feared()
  if feared then return self:runFrom(feared) end

  if self:inRange(target) then
    self.unit.animation:set('idle')
    return
  end

  self:moveTowards(target)
end

function UnitAI:moveTowards(target)
  local feared = self.unit.buffs:feared()
  if feared then return self:runFrom(feared) end

  if not target then
    self.unit.animation:set('idle')
    return
  end

  local targetx = type(target) == 'number' and target or target.x

  if math.abs(targetx - self.unit.x) <= 1 then
    self.unit.animation:set('idle')
    return
  end

  self.unit.x = self.unit.x + math.min(self.unit.speed * tickRate, math.abs(targetx - self.unit.x)) * math.sign(targetx - self.unit.x)
  self.unit.animation:set('walk')
  self.unit.animation.flipped = self.unit.x > targetx
end

function UnitAI:runFrom(target)
  self.unit.x = self.unit.x - self.unit.speed * math.sign(target.x - self.unit.x) * tickRate
  self.unit.animation:set('walk')
  self.unit.animation.flipped = self.unit.x < target.x
end

function UnitAI:startAttacking(target)
  local feared = self.unit.buffs:feared()
  if feared then return self:runFrom(feared) end

  if not self:inRange(target) or self.unit.buffs:stunned() then
    self.unit.animation:set('idle')
    return
  end

  self.unit.attackTarget = target
  if self.unit.animation.state.name ~= 'attack' then self.unit.attackStart = tick end
  self.unit.animation.flipped = self.unit.x > target.x
  self.unit.animation:set('attack')
end

function UnitAI:useAbilities()
  table.each(self.unit.abilities, function(ability)
    if ability:canUse() and love.math.random() < .5 then
      f.exe(ability.use, ability)
    end
  end)
end

