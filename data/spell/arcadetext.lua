local g = love.graphics

local ArcadeText = extend(Spell)

function ArcadeText:activate()
  self.vx = 0
  self.vy = -20
  self.x = self.x or 0
  self.y = self.y or 0
  self.prevx = self.x
  self.prevy = self.y
  self.alpha = 1
  ctx.event:emit('view.register', {object = self})
end

function ArcadeText:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function ArcadeText:update()
  self.prevx, self.prevy = self.x, self.y
  self.x = self.x + self.vx * tickRate
  self.y = self.y + self.vy * tickRate
  self.alpha = self.alpha - math.min(self.alpha, tickRate)
  if self.alpha <= 0 then ctx.spells:remove(self) end
end

function ArcadeText:draw()
  local alpha = math.clamp(self.alpha, 0, 1) * 255
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  g.setFont('pixel', 8)
  g.setColor(0, 0, 0, alpha)
  g.printCenter(self.text, x + 1, y + 1)
  g.setColor(255, 255, 255, alpha)
  g.printCenter(self.text, x, y)
end

return ArcadeText
