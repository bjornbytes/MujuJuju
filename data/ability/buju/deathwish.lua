local DeathWish = extend(Ability)

function DeathWish:preattack(target, amount)
  if target.health / target.maxHealth <= .2 then
    if love.math.random() < .2 + .2 * self.unit:upgradeLevel('deathwish') then
      amount = 100000000
    end
  end

  return amount
end

return DeathWish
