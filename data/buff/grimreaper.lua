local GrimReaper = extend(Buff)
GrimReaper.tags = {}

function GrimReaper:posthurt(amount, source, kind)
  if source and self.unit.health <= 0 then
    source:hurt(100000)
  end
end

return GrimReaper
