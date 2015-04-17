local tween = require 'lib/deps/tween/tween'

HudUpgrades = class()

function HudUpgrades:init()
  self.active = false
  self.lastPress = 0
  self.time = 0
  self.prevTime = self.time
  self.maxTime = .45
  self.factor = {value = 0}
  self.tween = tween.new(self.maxTime, self.factor, {value = 1}, 'inOutBack')
end

function HudUpgrades:update()
  self.prevTime = self.time
  local p = ctx.player
  if not p:atShrine() or p.dead then self.active = false end
  if self.active then self.time = math.min(self.time + ls.tickrate, self.maxTime)
  else self.time = math.max(self.time - ls.tickrate, 0) end
end

function HudUpgrades:keypressed(key)
  if not ctx.tutorial:shouldAllowUpgradeToggling() then return end
  if key == 'tab' or key == 'e' then
    self.lastPress = tick
    self.active = not self.active
    if not ctx.player:atShrine() then self.active = false end
  end
end

function HudUpgrades:keyreleased(key)
  if not ctx.tutorial:shouldAllowUpgradeToggling() then return end
  if key == 'tab' or key == 'e' or key == 'escape' then
    if (tick - self.lastPress) * ls.tickrate > self.maxTime then
      self.active = false
    end
  end
end

function HudUpgrades:gamepadpressed(gamepad, button)
  if button == 'x' then
    self:keypressed('tab')
  end
end

function HudUpgrades:gamepadreleased(gamepad, button)
  if button == 'x' then
    self:keyreleased('tab')
  end
end

function HudUpgrades:getFactor()
  local t = lume.lerp(self.prevTime, self.time, ls.accum / ls.tickrate)
  self.tween:set(t)
  return self.factor.value, t
end
