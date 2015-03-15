local ShadowRush = extend(Ability)
ShadowRush.ranges = {150, 225, 300}
ShadowRush.cooldowns = {12, 8, 4}

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

  if self.unit.target and math.abs(self.unit.target.x - self.unit.x) < self.ranges[level] and math.abs(self.unit.target.x - self.unit.x) > 75 then
    self.unit.x = self.unit.target.x - (self.unit.target.width / 2 + self.unit.width / 2) * self:getUnitDirection()
    ctx.sound:play(data.media.sounds.xuju.shadowrush)
  end
end

return ShadowRush
