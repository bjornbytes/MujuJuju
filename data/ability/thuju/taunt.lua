local Taunt = extend(Ability)
Taunt.code = 'taunt'

----------------
-- Behavior
----------------
function Taunt:activate()
  self.unit.animation:on('event', function(data)
    if data.data.name == 'taunt' then
      local range = 50 + 50 * self.unit:upgradeLevel('taunt')
      table.each(ctx.target:inRange(self.unit, range, 'enemy', 'unit'), function(target)
        target.buffs:add('taunt', {timer = 3, target = self.unit})
        ctx.sound:play('taunt')
      end)
    end
  end)
end

function Taunt:use()
  self.unit.animation:set('taunt')
  self.unit.casting = true
  self.timer = 14 - 2 * self.unit:upgradeLevel('taunt')
end

return Taunt
