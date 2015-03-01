local Puppetize = extend(Ability)

----------------
-- Data
----------------
Puppetize.cooldown = 30


----------------
-- Behavior
----------------
function Puppetize:use()
  if self.unit.target and isa(self.unit.target, Unit) then
    self.unit.target.buffs:add('puppetize', {timer = 3, owner = self.unit})
    self.unit.animation:set('puppetize')
    self.unit.channeling = true
    self.timer = self.cooldown
  end
end


return Puppetize
