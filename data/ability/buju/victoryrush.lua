local VictoryRush = extend(Ability)

function VictoryRush:kill()
  local level = self.unit:upgradeLevel('victoryrush')
  self.unit.buffs:add('victoryrush', {haste = .4 * level, timer = 2 + level})
end

return VictoryRush
