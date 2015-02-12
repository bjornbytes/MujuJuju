local EmpoweredStrikes = extend(Ability)

function EmpoweredStrikes:postattack()
  local buff = self.unit.buffs:get('empoweredstrikes')
  local amount = .05 + self.unit:upgradeLevel('empoweredstrikes') * .05
  if buff then buff.maxStacks = 1 + self.unit:upgradeLevel('empoweredstrikes') end
  buff = self.unit.buffs:add('empoweredstrikes', {timer = 5})
  buff.frenzy = amount * buff.stacks
end

return EmpoweredStrikes
