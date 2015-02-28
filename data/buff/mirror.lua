local Mirror = extend(Buff)
Mirror.tags = {}

function Mirror:preattack(target, amount)
  if target == ctx.shrine then
    self.unit:hurt(amount, ctx.shrine)
  end
end

return Mirror
