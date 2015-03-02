local Parasitic = extend(Buff)
Parasitic.tags = {'elite'}

function Parasitic:postattack(target, amount)
  if amount and type(amount) == 'number' then
    local lifesteal = amount * self.lifesteal
    self.unit:heal(lifesteal)
  end
end

return Parasitic
