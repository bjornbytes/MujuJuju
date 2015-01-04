Buff = class()

Buff.preupdate = f.empty
Buff.update = f.empty
Buff.postupdate = f.empty

Buff.activate = f.empty
Buff.deactivate = f.empty

function Buff:rot()
  if self.timer then
    self.timer = timer.rot(self.timer, function()
      self.unit.buffs:remove(self)
    end)
  end
end
