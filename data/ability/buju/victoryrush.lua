local VictoryRush = extend(Ability)

function VictoryRush:kill()
  local level = self.unit:upgradeLevel('victoryrush')
  self.unit.buffs:add('victoryrush', {haste = 2 ^ (level - 1) / 10, timer = 5})
end

return VictoryRush
