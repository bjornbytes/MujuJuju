local Fear = extend(Ability)
Fear.code = 'fear'
Fear.name = 'Fear'


----------------
-- Stats
----------------
Fear.cooldown = 10
Fear.range = 190
Fear.duration = 1.5


----------------
-- Behavior
----------------
function Fear:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'fear' then
      local target = ctx.target:closest(self.unit, self.range, 'enemy', 'unit')
      if target then
        target.buffs:add('fear', {timer = self.duration, target = self.unit})
        ctx.sound:play('fear', function(sound) sound:setVolume(.5) end)
      end
    end
  end)
end

function Fear:use()
  self.unit.animation:set('fear')
  self.unit.casting = true
  self.timer = self.cooldown
end

return Fear
