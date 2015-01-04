local WardOfThorns = extend(Ability)
WardOfThorns.code = 'wardofthorns'

----------------
-- Behavior
----------------
function WardOfThorns:prehurt(amount, source, kind)
  local reflects = {.10, .25, .45, .70, 1.00, 1.50}
  local reflect = reflects[self.unit:upgradeLevel('wardofthorns')]

  local melee = {'duju'}
  if kind == 'attack' and (source and source.class and table.has(melee, source.class.code)) then
    source:hurt(amount * reflect, self.unit)
  end
end

return WardOfThorns
