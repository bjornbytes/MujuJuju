local g = love.graphics

HudExperience = class()

function HudExperience:init()
  self.display = 0
  self.prevDisplay = self.display
end

function HudExperience:update()
  self.prevDisplay = self.display

  local p = ctx.player
  local prev = p.nextLevels[p.level - 1] or 0
  local target = 0
  if not p.nextLevels[p.level] then target = 0
  else target = (p.experience - prev) / (p.nextLevels[p.level] - prev) end
  if self.display > target then
    self.prevDisplay, self.display = target, target
  else
    self.display = math.lerp(self.display, target, math.min(10 * tickRate, 1))
  end
end

function HudExperience:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local height = .01 * v
  local display = math.lerp(self.prevDisplay, self.display, tickDelta / tickRate)
  g.setBlendMode('additive')
  g.setColor(150, 255, 0, 100)
  g.rectangle('fill', 0, v - height, display * u, height)
  g.setBlendMode('alpha')
end
