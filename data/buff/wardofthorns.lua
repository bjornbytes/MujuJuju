local WardOfThorns = extend(Buff)
WardOfThorns.code = 'wardofthorns'
WardOfThorns.name = 'Ward Of Thorns'
WardOfThorns.tags = {'reflect'}

function WardOfThorns:posthurt(amount, source, kind)
  local taunted = false
  table.each(source.buffs:buffsWithTag('taunt'), function(buff)
    if buff.target and buff.target == self.unit then
      taunted = true
      return false
    end
  end)

  if taunted and kind == 'attack' and source.range < 100 then
    source:hurt(amount * self.reflectAmount, self.unit)
  end
end

return WardOfThorns
