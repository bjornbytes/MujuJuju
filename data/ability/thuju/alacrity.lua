local Alacrity = extend(Ability)

function Alacrity:prehurt(amount, source, kind)
  if kind == 'attack' then
    table.each(self.unit.abilities, function(ability)
      if ability.timer > 0 then
        ability.timer = math.max(ability.timer - 1, 0)
      end
    end)
  end
end

return Alacrity
