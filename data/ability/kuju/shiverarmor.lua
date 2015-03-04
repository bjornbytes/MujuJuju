local ShiverArmor = extend(Ability)
ShiverArmor.cooldown = 10

function ShiverArmor:activate()
  self.timer = love.math.random() * self.cooldown
end

function ShiverArmor:update()
  --
end

return ShiverArmor
