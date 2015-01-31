Gamepad = class()

function Gamepad:load()
  self.joysticks = {}
end

function Gamepad:update()

end

function Gamepad:gamepadaxis(joystick, axis, value)
  print('gamepadaxis', joystick, axis, value)
end

function Gamepad:gamepadpressed(joystick, button)
  print('gamepadpressed', joystick, button)
end

function Gamepad:gamepadreleased(joystick, button)
  print('gamepadreleased', joystick, button)
end

function Gamepad:joystickadded(joystick)
  print('joystickadded', joystick, joystick:isGamepad())
  table.print(love.joystick.getJoysticks())
  table.insert(self.joysticks, joystick)
end

function Gamepad:joystickaxis(joystick, axis, value)
  print('joystickaxis', joystick, axis, value)
end

function Gamepad:joystickhat(joystick, hat, direction)
  print('joystickhat', joystick, hat, direction)
end

function Gamepad:joystickpressed(joystick, button)
  print('joystickpressed', joystick, button)
end

function Gamepad:joystickreleased(joystick, button)
  print('joystickreleased', joystick, button)
end

function Gamepad:joystickremoved(joystick)
  print('joystickremoved', joystick)
  table.each(self.joysticks, function(connectedJoystick, index)
    if connectedJoystick == joystick then
      table.remove(self.joysticks, index)
    end
  end)
end
