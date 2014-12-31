local Frostbite = extend(Ability)
Frostbite.code = 'frostbite'

----------------
-- Meta
----------------
Frostbite.name = 'Frostbite'
Frostbite.description = 'Kuju curses an area and makes it pretty darn cold for $duration second$s.  Enemies that walk through it are slowed by %slow and take $dps damage every second.  If an enemy stays in the zone for longer than $rootThreshold second$s, it is rooted for $rootDuration second$s.'


----------------
-- Data
----------------
Frostbite.cooldown = 18
Frostbite.target = 'location'
Frostbite.range = 150
Frostbite.width = 100
Frostbite.duration = 3
Frostbite.slow = .2
Frostbite.dps = 20
Frostbite.rootDuration = 1.5
Frostbite.rootThreshold = 2


----------------
-- Behavior
----------------
function Frostbite:use(target)
  local width, duration = self.width, self.rootDuration

  if self:hasUpgrade('tundra') then
    width = width + width * self.upgrades.tundra.widthIncrease
  end

  if self:hasUpgrade('frigidprison') then
    duration = self.upgrades.frigidprison.rootDuration
  end

  self:createSpell({
    x = target,
    width = width,
    rootDuration = duration
  })
end


----------------
-- Upgrades
----------------
local Tundra = {}
Tundra.code = 'tundra'
Tundra.name = 'Tundra'
Tundra.description = 'The size of the zone is increased by %widthIncrease.'
Tundra.widthIncrease = .5

local FrigidPrison = {}
FrigidPrison.code = 'frigidprison'
FrigidPrison.name = 'Frigid Prison'
FrigidPrison.description = 'The root duration is increased to $rootDuration second$s.'
FrigidPrison.rootDuration = 3

Frostbite.upgrades = {Tundra, FrigidPrison}

return Frostbite
