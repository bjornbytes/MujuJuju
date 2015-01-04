local ImpenetrableHide = extend(Ability)
ImpenetrableHide.code = 'impenetrablehide'

function ImpenetrableHide:posthurt(amount, source, kind)
  if not source then return end

  local buff = self.unit.buffs:get('impenetrablehide')
  local upgradeLevel = self.unit:upgradeLevel('impenetrablehide')
  if buff then
    buff.maxStacks = 3
    if upgradeLevel >= 4 then buff.maxStacks = upgradeLevel end
  end

  self.unit.buffs:add('impenetrablehide', {timer = 3})

  local buff = self.unit.buffs:get('impenetrablehide')
  if buff then
    buff.armor = (.02 + (.02 * upgradeLevel)) * buff.stacks
  end
end

return ImpenetrableHide
