local Slayer = extend(Buff)
Slayer.tags = {}

function Slayer:prehurt(amount, source, kind)
  return amount * (source.player and 2 or 1)
end

return Slayer
