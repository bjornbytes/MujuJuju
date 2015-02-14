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
    self.dingTimer = timer.rot(self.dingTimer)
  end

  local prev = p.nextLevels[p.level - 1] or 0
  if not p.nextLevels[p.level] then target = 0
  else target = (p.experience - prev) / (p.nextLevels[p.level] - prev) end

  self.display = math.lerp(self.display, target, math.min(10 * tickRate, 1))
end

function HudExperience:draw()
  if ctx.ded or ctx.tutorial then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.player
  local height = .025 * v
  local display = math.lerp(self.prevDisplay, self.display, tickDelta / tickRate)
  g.setBlendMode('additive')
  g.setColor(150, 255, 0, 100)
  g.rectangle('fill', 0, v - height, display * u, height)
  g.setBlendMode('alpha')

  g.setFont('mesmerize', height * .75)
  g.setColor(255, 255, 255)

  if p.nextLevels[p.level] then
    g.printShadow(math.round(p.experience) .. ' / ' .. p.nextLevels[p.level], u * .5, v - height / 2, true)
  end

  g.printShadow('Level ' .. p.level, v * .01, v - height - v * .01 - g.getFont():getHeight())

  if self.dingTimer > 0 then
    g.setFont('mesmerize', .08 * v)
    g.setColor(255, 255, 255, math.min(self.dingTimer / .2, 1) * 255)
    g.printCenter('Level Up!', u * .5, v * .4, true)
  end
end
