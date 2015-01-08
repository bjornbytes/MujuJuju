local Spinach = extend(Buff)
Spinach.code = 'spinach'
Spinach.name = 'Spinach'
Spinach.tags = {}

function Spinach:preattack(target, damage)
  return damage * 1.5
end


return Spinach
