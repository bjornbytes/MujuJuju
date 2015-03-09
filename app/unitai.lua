UnitAI = class()

function UnitAI:update()

  -- Try to find something to attack
  self:changeTarget(ctx.target:closest(self.unit, 'enemy', 'shrine', 'player', 'unit'))
  local target = self.unit.target

  -- Give up if there is no target
  if not target or target.untargetable then
    self.unit.target = nil
    target = nil
  end

  if target then
    if self:inRange(target) then
      self:startAttacking(target)
    else
      self:moveIntoRange(target)
    end
  else
    self.unit.animation:set('idle')
  end
end

function UnitAI:changeTarget(target)
  local taunt = self.unit.buffs:taunted()
  self.unit.target = taunt or target
end

function UnitAI:inRange(target)
  return math.abs(target.x - self.unit.x) <= self.unit.range + target.width / 2 + self.unit.width / 2
end

function UnitAI:moveIntoRange(target)
  local fear = self.unit.buffs:feared()
  if fear then return self:runFrom(fear.target) end

  if self:inRange(target) then
    self.unit.animation:set('idle')
    return
  end

  self:moveTowards(target)
end

function UnitAI:moveTowards(target)
  local fear = self.unit.buffs:feared()
  if fear then return self:runFrom(fear.target) end

  if not target then
    self.unit.animation:set('idle')
    return
  end

  local targetx = type(target) == 'number' and target or target.x

  if math.abs(targetx - self.unit.x) <= 1 then
    self.unit.animation:set('idle')
    return
  end

  self.unit.x = self.unit.x + math.min(self.unit.speed * ls.tickrate, math.abs(targetx - self.unit.x)) * math.sign(targetx - self.unit.x)
  self.unit.animation:set('walk')
  self.unit.animation.flipped = self.unit.x > targetx
end

function UnitAI:runFrom(target)
  self.unit.x = self.unit.x - self.unit.speed * math.sign(target.x - self.unit.x) * ls.tickrate
  self.unit.animation:set('walk')
  self.unit.animation.flipped = self.unit.x < target.x
end

function UnitAI:startAttacking(target)
  local fear = self.unit.buffs:feared()
  if fear then return self:runFrom(fear.target) end

  if not self:inRange(target) or self.unit.buffs:stunned() then
    self.unit.animation:set('idle')
    return
  end

  self.unit.target = target
  if self.unit.animation.state.name ~= 'attack' then self.unit.attackStart = tick end
  self.unit.animation.flipped = self.unit.x > target.x
  self.unit.animation:set('attack')
end

function UnitAI:useAbilities()
  if self.unit.buffs:silenced() or ctx.tutorial.active then return end

  table.each(self.unit.abilities, function(ability)
    if ability:canUse() and love.math.random() < .5 then
      f.exe(ability.use, ability)
    end
  end)
end

