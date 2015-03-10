local FrozenOrb = extend(Ability)

FrozenOrb.runeDamage = 0
FrozenOrb.runeSlow = 0
FrozenOrb.runeKnockback = 0
FrozenOrb.spiritRatios = {[0] = 0, .4, .8, 1.2, 1.6, 2.0}

----------------
-- Behavior
----------------
function FrozenOrb:activate()
  self.timer = love.math.random() * 10 - self.unit:upgradeLevel('frozenorb')

  self.unit.animation:on('event', function(event)
    if event.data.name == 'frozenorb' then
      ctx.sound:play(data.media.sounds.kuju.frozenorb)
      self:createSpell('frozenorb', {})
      self.timer = 10 - self.unit:upgradeLevel('frozenorb')
    end
  end)
end

function FrozenOrb:use()
  if self.unit.target and not isa(self.unit.target, Shrine) then
    self.unit.animation:set('frozenorb')
    self.unit.casting = true
  end
end

function FrozenOrb:bonuses()
  local bonuses = {}
  local frozenorb = data.unit.kuju.upgrades.frozenorb.level

  local spirit = Unit.getStat('kuju', 'spirit')
  if spirit > 0 then
    table.insert(bonuses, {'Spirit', math.round(spirit * self.spiritRatios[frozenorb]), 'damage'})
  end

  if self.runeDamage > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeDamage), 'damage'})
  end

  if self.runeSlow > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeSlow * 100) .. '%', 'slow'})
  end

  return bonuses
end

return FrozenOrb

