Buff = class()

Buff.activate = f.empty
Buff.deactivate = f.empty
Buff.update = f.empty

function Buff:rot()
  if self.timer then
    local rate = ls.tickrate

    if self.unit then
      if self.unit.buffs:isCrowdControl(self.code) then
        local immunity = self.unit.buffs:ccImmunity()
        if immunity == 1 then self.timer = 0
        else rate = rate / (1 - immunity) end
      end

      self.timer = self.timer - rate
      if self.timer <= 0 then
        self.unit.buffs:remove(self)
      end
    elseif self.player then
      self.timer = self.timer - rate
      if self.timer <= 0 then
        self.player.buffs:remove(self)
      end
    end
  end
end

function Buff:getUnitDirection()
  return (self.unit.animation.flipped and -1 or 1)
end
