local Rend = extend(Ability)

----------------
-- Stats
----------------
Rend.cooldown = 4


----------------
-- Behavior
----------------
function Rend:activate()
  self.unit.animation:on('event', function(event)
    if event.data.name == 'rend' and self.unit.target then
      local targets = {self.unit.target}
      local rendLevel = self.unit:upgradeLevel('rend')
      local darkRendLevel = self.unit:upgradeLevel('darkrend')
      local damage = level == 1 and self.unit.damage or self.unit.damage * 1.5

      local dot = level == 1 and 5 or 10
      dot = ctx.player.dead and (dot * (1 + darkRendLevel / 4)) or dot

      if self.unit:upgradeLevel('twinblades') > 0 then
        local target, distance = ctx.target:closest(self.unit.target, 'ally', 'unit')

        if distance <= 30 then
          table.insert(targets, target)
        end
      end

      table.each(targets, function(target)
        self.unit:attack({target = target, damage = damage})
        target.buffs:add('rend', {dot = dot, timer = 3})
      end)
    end
  end)
end

function Rend:use()
  if self.unit.target and isa(self.unit.target, Unit) then
    self.unit.animation:set('rend')
    self.unit.casting = true
    self.timer = self.cooldown
  end
end

return Rend
