local InfusedCarapace = extend(Ability)

function InfusedCarapace:prehurt(amount, source, kind)
  if kind and table.has(kind, 'spell') then
    return amount * .65
  end

  return amount
end

return InfusedCarapace
