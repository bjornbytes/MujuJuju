local Taunt = extend(Ability)
Taunt.code = 'taunt'

----------------
-- Behavior
----------------
function Taunt:activate()
  self.unit.animation:on('event', function(data)
    if data.data.name == 'taunt' then
      print('lol taunted')
    end
  end)
end

function Taunt:use()
  self.unit.animation:set('taunt')
  self.unit.casting = true
end

return Taunt
