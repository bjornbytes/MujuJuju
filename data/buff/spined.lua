local Spined = extend(Buff)
Spined.tags = {'elite'}

function Spined:prehurt(amount, source, kind)
  if source then
    source:hurt(amount * self.reflect, self.unit)
  end
  
  return amount
end

return Spined
