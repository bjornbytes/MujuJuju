local Tremor = extend(Ability)
Tremor.code = 'tremor'

----------------
-- Behavior
----------------
function Tremor:activate()
  self.unit.animation:on('event', function(data)
    if data.data.name == 'tremor' then
      local level = self.unit:upgradeLevel('tremor')
      local damages = {[0] = 0, 30, 50, 80}
      local damage = damages[level]
      local stun = .5 * level
      local widths = {[0] = 0, 100, 150, 175}
      local width = widths[level]

      self:createSpell({damage = damage, width = width, stun = stun})
    end
  end)
end

function Tremor:use()
  self.unit.animation:set('tremor')
  self.unit.casting = true
  self.timer = 12
end

return Tremor
