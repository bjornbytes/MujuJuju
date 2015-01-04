local Spined = extend(Buff)
Spined.code = 'spined'
Spined.name = 'Spined'
Spined.tags = {'elite'}

function Spined:prehurt(amount, source, kind)
  source:hurt(amount * self.reflect, self.unit)
  return amount
end

return Spined
