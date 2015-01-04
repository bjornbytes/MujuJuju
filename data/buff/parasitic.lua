local Parasitic = extend(Buff)
Parasitic.code = 'parasitic'
Parasitic.name = 'Parasitic'
Parasitic.tags = {'elite'}

function Parasitic:postattack(target, amount)
  if amount then
    local lifesteal = amount * self.lifesteal
    self.unit:heal(lifesteal)
  end
end

return Parasitic
