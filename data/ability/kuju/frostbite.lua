local Frostbite = extend(Ability)

----------------
-- Meta
----------------
Frostbite.name = 'Frostbite'
Frostbite.description = 'Kuju curses an area and makes it pretty darn cold for $duration second$s.  Enemies that walk through it are slowed by %slow and take $dps damage every second.  If an enemy stays in the zone for longer than $rootThreshold second$s, it is rooted for $rootDuration second$s.'


----------------
-- Data
----------------
Frostbite.cooldown = 10
Frostbite.width = 100


----------------
-- Behavior
----------------
function Frostbite:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'frostbite' then
      local target = ctx.target:closest(self.unit, 'enemy', 'unit')
      if target and math.abs(self.unit.x - target.x) <= self.unit.range + self.unit.width / 2 + target.width / 2 then
        self:createSpell({x = target.x})
      end
    end
  end)
end

function Frostbite:use(target)
  if self.unit.target and isa(self.unit.target, Unit) then
    self.unit.animation:set('frostbite')
    self.unit.casting = true
    self.timer = self.cooldown
  end
end

return Frostbite
