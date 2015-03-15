local Ambush = extend(Ability)

Ambush.cooldown = 8
Ambush.damage = 50
Ambush.spiritRatio = 1

function Ambush:activate()
  self.target = nil
  self.unit.animation:on('event', function(event)
    if event.data.name == 'vanish' then
      local target = ctx.target:closest(self.unit, 'enemy', 'unit')
      if target then
        self.unit.x = target.x - (target.animation.flipped and -1 or 1) * (self.unit.width / 2)
        self.unit.target = target
        self.unit.animation:set('rend', {force = true})
        self.target = target
      end

      self.unit.untargetable = false
      self.unit.casting = false
    elseif event.data.name == 'rend' and self.target then
      if self.target then
        local damage = self.damage + self.spiritRatio * self.unit.spirit
        self.target:hurt(damage, self.unit, {})
      end
    end
  end)
end

function Ambush:update()
  if ctx.player.dead and self.timer == 0 then
    self.timer = self.cooldown
    self:fire()
  end
end

function Ambush:fire()
  self.unit.animation:set('vanish')
  self.unit.untargetable = true
  self.unit.casting = true
end

function Ambush:bonuses()
  local bonuses = {}
  local spirit = Unit.getStat('xuju', 'spirit')
  if spirit > 0 then
    table.insert(bonuses, {'Spirit', math.round(spirit * self.spiritRatio), 'damage'})
  end
  return bonuses
end

return Ambush
