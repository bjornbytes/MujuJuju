local WardOfThorns = extend(Ability)

WardOfThorns.reflect = 0
WardOfThorns.perstack = 0

function WardOfThorns:prehurt(amount, source, kind)
  if not source or not kind then return end
  local melee = source.range < 100
  if table.has(kind, 'attack') then
    local reflects = {.10, .25, .45, .70, 1.00}
    local reflect = self.reflect + reflects[self.unit:upgradeLevel('wardofthorns')]

    local function applyVigor()
      if self.unit:upgradeLevel('vigor') > 0 then
        local buff = self.unit.buffs:get('vigor')
        if buff then buff.maxStacks = 1 + self.unit:upgradeLevel('vigor') end
        buff = self.unit.buffs:add('vigor', {timer = 5})

        if self.unit:upgradeLevel('impenetrablehide') > 0 then
          buff.armor = (.05 + (.05 * self.unit:upgradeLevel('impenetrablehide') * buff.stacks))
          if self.unit:upgradeLevel('unbreakable') > 0 then
            buff.armorRangedMultiplier = 1.5
          end
        end
      end
    end

    if melee then
      source:hurt(amount * reflect, self.unit)
      applyVigor()
    elseif self.unit:upgradeLevel('briarlance') > 0 then
      source:hurt(amount * reflect * .75, self.unit)
      applyVigor()
    end
  end
end

return WardOfThorns
