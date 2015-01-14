local Inspire = extend(Ability)

function Inspire:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'taunt' then
      local range = 150
      local level = self.unit:upgradeLevel('inspire')
      local targets = ctx.target:inRange(self.unit, range, 'ally', 'unit')
      table.each(targets, function(target)
        target.buffs:add('inspire', {
          timer = 3,
          haste = .5,
          armor = level >= 2 and .5 or 0,
          frenzy = level >= 3 and .5 or 0
        })
      end)

      ctx.sound:play(data.media.sounds.thuju.taunt)
    end
  end)
end

function Inspire:use()
  self.unit.animation:set('taunt')
  self.unit.casting = true
  self.timer = 12
end

return Inspire
