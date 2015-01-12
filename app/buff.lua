Buff = class()

Buff.preupdate = f.empty
Buff.update = f.empty
Buff.postupdate = f.empty

Buff.activate = f.empty
Buff.deactivate = f.empty

function Buff:rot()
  if self.timer then
    local rate = tickRate

    if self.unit.buffs:isCrowdControl(self.code) then
      local immunity = self.unit.buffs:ccImmunity()
      if immunity == 1 then self.timer = 0
      else rate = rate / (1 - immunity) end
    end

    self.timer = self.timer - rate
    if self.timer <= 0 then
      self.unit.buffs:remove(self)
    end
  end
end
