local Demolisher = extend(Buff)
Demolisher.tags = {'elite'}

function Demolisher:preattack(target, damage)
  if target == ctx.shrine then
    return damage * self.damageModifier
  end
end

return Demolisher
