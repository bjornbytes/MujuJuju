local Tremor = extend(Ability)

Tremor.damages = {30, 60, 90}
Tremor.spiritRatio = 1.5
Tremor.runeDamage = 0
Tremor.runeStun = 0

function Tremor:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'tremor' then
      self:fire()
    end
  end)

  if self.unit:upgradeLevel('staggeringentry') > 0 then self:fire() end
end

function Tremor:use()
  self.unit.animation:set('tremor')
  self.unit.casting = true
  self.timer = 12
end

function Tremor:fire()
  local level = self.unit:upgradeLevel('tremor')
  local damages = self.damages
  local damage = self.runeDamage + damages[level] + self.spiritRatio * self.unit.spirit
  local stun = self.runeStun + 1 * level
  local width = 180 + (60 * self.unit:upgradeLevel('fissure'))

  self:createSpell({damage = damage, width = width, stun = stun, spikeCount = math.round(width / 60)})

  ctx.sound:play(data.media.sounds.thuju.tremor, function(sound) sound:setVolume(.5) end)
end

function Tremor:bonuses()
  local bonuses = {}

  local spirit = Unit.getStat('thuju', 'spirit')
  if spirit > 0 then
    table.insert(bonuses, {'Spirit', spirit * self.spiritRatio, 'damage'})
  end

  if self.runeDamage > 0 then
    table.insert(bonuses, {'Runes', self.runeDamage, 'damage'})
  end

  if self.runeStun > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeStun * 10) / 10 .. 's', 'stun duration'})
  end

  return bonuses
end

return Tremor
