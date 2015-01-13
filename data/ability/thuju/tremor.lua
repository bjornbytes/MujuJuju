local Tremor = extend(Ability)

----------------
-- Behavior
----------------
function Tremor:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'tremor' then
      local level = self.unit:upgradeLevel('tremor')
      local damages = {[0] = 0, 30, 60, 90}
      local damage = damages[level]
      local stun = 1 + .5 * level
      local width = 175

      self:createSpell({damage = damage, width = width, stun = stun})

      ctx.sound:play(data.media.sounds.thuju.tremor, function(sound) sound:setVolume(.5) end)
    end
  end)
end

function Tremor:use()
  self.unit.animation:set('tremor')
  self.unit.casting = true
  self.timer = 12
end

return Tremor
