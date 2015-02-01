VirtualCursor = class()

function VirtualCursor:init()
  self.cursorSpeed = 0
end

function VirtualCursor:getUV()
  return ctx.u, ctx.v
end

function VirtualCursor:update()
  local joysticks = love.joystick.getJoysticks()

  if #joysticks > 0 then
    local u, v = self:getUV()
    table.each(joysticks, function(joystick)
      local cursorSpeed = .625 * u
      local x, y = love.mouse.getPosition()
      local xx, yy = joystick:getGamepadAxis('leftx'), joystick:getGamepadAxis('lefty')
      local len = (xx * xx + yy * yy) ^ .5

      if len < .2 then len = 0 end

      local vx, vy = xx / len, yy / len
      self.cursorSpeed = math.lerp(self.cursorSpeed, len > 0 and cursorSpeed or 0, 18 * tickRate)
      vx = math.clamp(vx, -1, 1)
      vy = math.clamp(vy, -1, 1)
      vx = vx * self.cursorSpeed * len
      vy = vy * self.cursorSpeed * len
      love.mouse.setPosition(x + vx * tickRate, y + vy * tickRate)
    end)
  end
end
