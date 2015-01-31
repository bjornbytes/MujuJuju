local Puppetize = extend(Ability)

----------------
-- Data
----------------
Puppetize.cooldown = 14


----------------
-- Behavior
----------------
function Puppetize:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'puppetize' then
      local target = ctx.target:closest(self, 'enemy', 'unit')
      if target and math.abs(self.unit.x - target.x) <= self.unit.range + self.unit.width / 2 + target.width / 2 then
        target.buffs:add('puppetize', {timer = 4})
      end
    end
  end)
end

function Puppetize:use()
  if self.unit.target and isa(self.unit.target, Unit) then
    self.unit.animation:set('puppetize')
    self.unit.casting = true
    self.timer = self.cooldown
  end
end


return Puppetize
