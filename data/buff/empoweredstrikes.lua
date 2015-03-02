local EmpoweredStrikes = extend(Buff)
EmpoweredStrikes.tags = {}

function EmpoweredStrikes:activate()
  self.charges = 0
  ctx.event:on('juju.collected', function()
    self.charges = math.min(self.charges + 1, 3)
  end)
end

function EmpoweredStrikes:preattack(target, amount)
  if self.charges > 0 then
    return amount * 1.5
  end

  return amount
end

function EmpoweredStrikes:postattack(target, amount)
  if self.charges > 0 then
    self.charges = self.charges - 1
    self.unit:heal(amount * .25, self.unit)
  end
end

return EmpoweredStrikes
