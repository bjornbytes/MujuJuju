local Parasitic = extend(Buff)
Parasitic.tags = {'elite'}

function Parasitic:postattack(target, amount)
  if amount then
    local lifesteal = amount * self.lifesteal
    self.unit:heal(lifesteal)
  end
end

return Parasitic
