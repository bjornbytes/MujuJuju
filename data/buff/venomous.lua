local Venomous = extend(Buff)
Venomous.tags = {'elite'}

function Venomous:preattack(target, damage)
  if isa(target, Unit) then
    target.buffs:add('venom', {
      dot = self.unit.damage * self.dotModifier,
      timer = self.dotTimer
    })
  end
end

return Venomous
