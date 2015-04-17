local Frostbite = extend(Ability)
Frostbite.cooldown = 20

Frostbite.runeDamage = 0
Frostbite.runeSize = 0

----------------
-- Behavior
----------------
function Frostbite:activate()
  self.timer = love.math.random() * self.cooldown

  self.unit.animation:on('event', function(event)
    if event.data.name == 'frostbite' then
      local target = ctx.target:closest(self.unit, 'enemy', 'unit')
      if target and math.abs(self.unit.x - target.x) <= self.unit.range + self.unit.width / 2 + target.width / 2 then
        self:createSpell({x = target.x})
        self.timer = self.cooldown
      end
    end
  end)
end

function Frostbite:use(target)
  if self.unit.target and isa(self.unit.target, Unit) then
    self.unit.animation:set('frostbite')
    self.unit.casting = true
  end
end

function Frostbite:bonuses()
  local bonuses = {}

  if self.runeDamage > 0 then
    table.insert(bonuses, {'Runes', lume.round(self.runeDamage), 'damage'})
  end

  if self.runeSize > 0 then
    table.insert(bonuses, {'Runes', lume.round(self.runeSize * 100) .. '%', 'size'})
  end

  return bonuses
end

return Frostbite
