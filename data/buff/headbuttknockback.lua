local HeadbuttKnockback = extend(Buff)
HeadbuttKnockback.code = 'headbuttknockback'
HeadbuttKnockback.name = 'Headbutt'
HeadbuttKnockback.tags = {'knockback'}

function HeadbuttKnockback:update()
  local sign = math.sign(self.offset)
  local amount = math.ceil(math.max(math.abs(self.offset) * tickRate / .1, 100 * tickRate))

  if ctx.tag == 'server' then self.unit.x = self.unit.x + amount * sign end

  self.offset = self.offset - (amount * sign)
  if self.offset == 0 then self.unit.buffs:remove(self) end
  if self.ability:hasUpgrade('bash') then
    self.unit.buffs:add('headbuttstun', {
      stun = self.ability.upgrades.bash.stunDuration,
      timer = self.ability.upgrades.bash.stunDuration
    })
  end
  if self.ability:hasUpgrade('razorhorns') then
    self.unit.buffs:add('razorhorns', {
      dot = self.ability.upgrades.razorhorns.dot,
      timer = self.ability.upgrades.razorhorns.upgrade.duration,
      slow = self.ability.upgrades.razorhorns.upgrade.slowAmount
    })
  end
end

return HeadbuttKnockback
