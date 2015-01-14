local Vigor = extend(Buff)
Vigor.tags = {'damage', 'armor'}
Vigor.armor = 0
Vigor.stack = true

function Vigor:preattack(target, amount)
  local perStack = 5 + (5 * self.stacks)
  return damage + (self.stacks * perStack)
end

return Vigor
