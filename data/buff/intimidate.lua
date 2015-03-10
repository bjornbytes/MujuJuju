local Intimidate = extend(Buff)
Intimidate.tags = {}

function Intimidate:preattack(target, amount)
  return amount / 2
end

return Intimidate
