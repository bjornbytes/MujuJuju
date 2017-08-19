local GrimReaper = extend(Buff)
GrimReaper.tags = {}

function GrimReaper:posthurt(amount, source, kind)
  if source and self.unit.health <= 0 then
    self.unit:attack({ target = source })
  end
end

return GrimReaper
