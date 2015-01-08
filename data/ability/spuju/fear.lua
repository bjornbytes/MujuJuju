local Fear = extend(Ability)
Fear.code = 'fear'
Fear.name = 'Fear'


----------------
-- Stats
----------------
Fear.cooldown = 12
Fear.range = 190
Fear.duration = 2.5


----------------
-- Behavior
----------------
function Fear:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'fear' then
      local target = ctx.target:closest(self.unit, 'enemy', 'unit')
      if target and math.abs(self.unit.x - target.x) <= self.range + self.unit.width / 2 + target.width / 2 then
        target.buffs:add('fear', {timer = self.duration, target = self.unit})
        ctx.sound:play(data.media.sounds.spuju.fear, function(sound) sound:setVolume(.5) end)
      end
    end
  end)
end

function Fear:use()
  if self.unit.target and isa(self.unit.target, Unit) then
    self.unit.animation:set('fear')
    self.unit.casting = true
    self.timer = self.cooldown
  end
end

return Fear
