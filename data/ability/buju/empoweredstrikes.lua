local EmpoweredStrikes = extend(Ability)
EmpoweredStrikes.perStack = 0

function EmpoweredStrikes:postattack()
  local buff = self.unit.buffs:get('empoweredstrikes')
  local amount = self.perStack + .05 + self.unit:upgradeLevel('empoweredstrikes') * .05
  if buff then buff.maxStacks = 1 + self.unit:upgradeLevel('empoweredstrikes') end
  buff = self.unit.buffs:add('empoweredstrikes', {timer = 5})
  buff.frenzy = buff.stack and amount * buff.stacks or amount
end

return EmpoweredStrikes
