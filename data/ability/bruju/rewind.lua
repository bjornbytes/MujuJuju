local Rewind = extend(Ability)
Rewind.code = 'rewind'

function Rewind:activate()
  self.amount = 0
end

function Rewind:update()
  if self.amount > 0 then
    local rate = self.unit.maxHealth * .25
    local amount = math.min(self.amount, rate * tickRate)
    self.amount = self.amount - amount
    self.unit:heal(amount, self.unit)
  end
end

function Rewind:posthurt(amount, source, kind)
  if love.math.random() < .3 then
    self.amount = self.amount + amount
  end
end

return Rewind
