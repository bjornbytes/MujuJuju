local Pummeling = extend(Buff)
Pummeling.tags = {'elite'}

function Pummeling:preattack(target, damage)
  if isa(target, Unit) then
    target.buffs:add('pummelingknockback', {
      offset = self.offset * self:getUnitDirection()
    })
  end
end

return Pummeling
