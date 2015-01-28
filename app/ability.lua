Ability = class()

function Ability:init()
  self.timer = 0
end

function Ability:createSpell(code, vars)
  if not vars then code, vars = self.code, code end
  ctx.spells:add(data.spell[self.unit.class.code][code], table.merge(vars, {ability = self}, true))
end

function Ability:getUnitDirection()
  return (self.unit.animation.flipped and -1 or 1)
end

function Ability:canUse()
  return self.timer == 0
end

function Ability:rot()
  self.timer = self.timer - math.min(self.timer, tickRate * self.unit.haste)
  if self.timer <= 0 then
    f.exe(self.ready, self)
  end
end

function Ability:used()
  self.timer = self.cooldown or 0
end
