local GrimReaper = extend(Buff)
GrimReaper.tags = {}

function GrimReaper:posthurt()
  if self.unit.health <= 0 and not self.dead then
    self.dead = true
    self.unit.untargetable = true
    self.timer = 5
    self.unit.health = self.unit.maxHealth
  end
end

function GrimReaper:deactivate()
  self.unit:hurt(self.unit.maxHealth)
end


return GrimReaper
