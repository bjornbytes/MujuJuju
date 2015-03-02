local ShadowRush = extend(Ability)
ShadowRush.ranges = {200, 250, 300}
ShadowRush.cooldowns = {10, 8, 6}

function ShadowRush:update()
  local level = self.unit:upgradeLevel('shadowrush')
  if self.timer == 0 and self.unit.target and math.abs(self.unit.target.x - self.unit.x) < self.ranges[level] then
    self:fire()
    self.timer = self.cooldowns[level]
  end
end

function ShadowRush:fire()
  local level = self.unit:upgradeLevel('shadowrush')
  self.unit.animation:set('dash')

  if self.unit.target and math.abs(self.unit.target.x - self.unit.x) < self.ranges[level] then
    self.unit.x = self.unit.target.x - (self.unit.target.width / 2 + self.unit.width / 2) * self:getUnitDirection()
  end
end

return ShadowRush
