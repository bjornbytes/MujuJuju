local Spined = extend(Buff)
Spined.tags = {'elite'}

function Spined:prehurt(amount, source, kind)
  source:hurt(amount * self.reflect, self.unit)
  return amount
end

return Spined
