local Taunt = extend(Ability)
Taunt.code = 'taunt'

----------------
-- Behavior
----------------
function Taunt:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'taunt' then
      local range = 50 + 50 * self.unit:upgradeLevel('taunt')
      local target = ctx.target:inRange(self.unit, range, 'enemy', 'unit')
      table.each(targets, function(target)
        target.buffs:add('taunt', {timer = 3, target = self.unit})
        ctx.sound:play(data.media.sounds.thuju.taunt)
      end)

      self.unit.buffs:add('tauntdamage', {damage = 15 * table.count(targets), timer = 5})
    end
  end)
end

function Taunt:use()
  self.unit.animation:set('taunt')
  self.unit.casting = true
  self.timer = 12 - 2 * self.unit:upgradeLevel('taunt')
end

return Taunt
