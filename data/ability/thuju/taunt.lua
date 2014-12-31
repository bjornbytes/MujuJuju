local Taunt = extend(Ability)
Taunt.code = 'taunt'

----------------
-- Meta
----------------
Taunt.name = 'Taunt'
Taunt.description = 'Thuju taunts by beating his manly chest, forcing the nearest $targets target$s to attack him for $duration second$s.'


----------------
-- Data
----------------
Taunt.cooldown = 5
Taunt.range = 100
Taunt.targets = 2
Taunt.duration = 3


----------------
-- Behavior
----------------
function Taunt:use()
  local targets = table.take(ctx.target:inRange(self.unit, self.range, 'enemy', 'unit'), self.targets)
  table.each(targets, function(target)
    target.buffs:add('taunt', {target = self.unit, timer = self.duration})
  end)

  if self:hasUpgrade('impenetrablehide') then
    self.unit.buffs:add('impenetrablehide', {timer = self.duration, armor = self.upgrades.impenetrablehide.armor})
  end

  if self:hasUpgrade('wardofthorns') then
    self.unit.buffs:add('wardofthorns', {reflectAmount = self.upgrades.wardofthorns.reflectAmount})
  end
end


----------------
-- Upgrades
----------------
local ImpenetrableHide = {}
ImpenetrableHide.code = 'impenetrablehide'
ImpenetrableHide.name = 'Impenetrable Hide'
ImpenetrableHide.description = 'Thuju also takes %armor reduced damage from all attacks while taunting.'
ImpenetrableHide.armor = .4

local WardOfThorns = {}
WardOfThorns.code = 'wardofthorns'
WardOfThorns.name = 'Ward of Thorns'
WardOfThorns.description = 'Thuju\'s thorns get up in the grill of taunted melee enemies, reflecting %reflectAmount of the damage Thuju takes back at the attacker.'
WardOfThorns.reflectAmount = .5

Taunt.upgrades = {ImpenetrableHide, WardOfThorns}

return Taunt
