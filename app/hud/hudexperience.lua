local g = love.graphics

HudExperience = class()

function HudExperience:init()
  self.display = 0
  self.prevDisplay = self.display
  self.dingTimer = 0
  self.playerLevel = 1
end

function HudExperience:update()
  self.prevDisplay = self.display

  local p = ctx.player
  local target = 0

  if self.playerLevel ~= p.level then
    self.playerLevel = p.level
    self.dingTimer = 2
  end

  if self.dingTimer > 0 then
    target = 1
    self.dingTimer = timer.rot(self.dingTimer, function()
      self.display = 0
      self.prevDisplay = 0
    end)
  else
    local prev = p.nextLevels[p.level - 1] or 0
    if not p.nextLevels[p.level] then target = 0
    else target = (p.experience - prev) / (p.nextLevels[p.level] - prev) end
  end

  self.display = math.lerp(self.display, target, math.min(10 * tickRate, 1))
end

function HudExperience:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local height = .01 * v
  local display = math.lerp(self.prevDisplay, self.display, tickDelta / tickRate)
  g.setBlendMode('additive')
  g.setColor(150, 255, 0, 100)
  g.rectangle('fill', 0, v - height, display * u, height)
  g.setBlendMode('alpha')

  if self.dingTimer > 0 then
    g.setFont('mesmerize', .1 * v)
    g.setColor(255, 255, 255, math.min(self.dingTimer / .2, 1) * 255)
    g.printShadow('Level Up!', u * .5, v * .5, true)
  end
end
