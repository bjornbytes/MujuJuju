local Headbutt = extend(Ability)
Headbutt.code = 'headbutt'


----------------
-- Data
----------------
Headbutt.cooldown = 5
Headbutt.knockbackDistance = 100
Headbutt.damageModifier = 1.5


----------------
-- Behavior
----------------
function Headbutt:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'headbutt' then
      local targets = ctx.target:inRange(self.unit, 100, 'enemy', 'unit')
      local count = table.count(targets)
      local damage = (self.unit.damage * self.damageModifier) / count
      table.each(targets, function(target)
        if math.sign(target.x - self.unit.x) == self:getUnitDirection() then
          target.buffs:add('headbutt', {offset = self.knockbackDistance * self:getUnitDirection()})
          target:hurt(damage, self.unit)
        end
      end)
    end
  end)
end

function Headbutt:use()
  self.unit.animation:set('headbutt')
  self.unit.casting = true
  self.timer = self.cooldown
end

return Headbutt
