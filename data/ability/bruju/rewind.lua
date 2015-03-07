local Rewind = extend(Ability)

Rewind.runeChance = 0

function Rewind:activate()
  self.amount = 0
end

function Rewind:update()
  if self.amount > 0 then
    local rate = self.unit.maxHealth * .5
    local amount = math.min(self.amount, rate * ls.tickrate)
    self.amount = self.amount - amount
    self.unit:heal(amount, self.unit)
  end
end

function Rewind:posthurt(amount, source, kind)
  if love.math.random() < self.runeChance + .05 * self.unit:upgradeLevel('rewind') then
    self.amount = self.amount + amount

    if self.unit:upgradeLevel('impulse') > 0 then
      local _, burst = self.unit:hasAbility('burst')
      if burst then
        burst:die()
      end
    end
  end
end

function Rewind:bonuses()
  local bonuses = {}
  if self.runeChance > 0 then
    table.insert(bonuses, {'Runes', math.round(self.runeChance * 100) .. '%', 'chance'})
  end
  return bonuses
end

return Rewind
