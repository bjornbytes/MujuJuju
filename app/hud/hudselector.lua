HudSelector = class()

local g = love.graphics

function HudSelector:init()
  self.active = false
  self.alpha = 0
  self.x1 = nil
  self.x2 = nil
  self.prevx2 = nil
end

function HudSelector:update()
  if love.mouse.isDown('l') then
    if not self.active then
      self.x1 = love.mouse.getX()
      self.x2 = love.mouse.getX()
    end
    self.active = true
  else
    self.prevx2 = self.x2

    if self.x1 and self.x2 and self.active then
      local p = ctx.player
      local x1, x2 = self.x1, self.x2
      if x1 > x2 then x1, x2 = x2, x1 end
      for i = 1, #p.deck do
        local instance = p.deck[i].instance
        if not love.keyboard.isDown('lshift') then p.deck[i].selected = false end
        if instance and  instance.x >= x1 and instance.x <= x2 then
          p.deck[i].selected = true
        end
      end
    end

    self.active = false
  end

  if self.active then
    self.prevx2 = self.x2
    self.x2 = math.lerp(self.x2, love.mouse.getX(), 12 * tickRate)
  end

  if not self.active or math.abs(self.x1 - self.x2) > 2 then
    self.alpha = math.lerp(self.alpha, self.active and 1 or 0, 5 * tickRate)
  end
end

function HudSelector:draw()
  if not self.x1 or not self.x2 then return end

  local x2 = math.lerp(self.prevx2, self.x2, tickDelta / tickRate)

  local x = math.min(self.x1, x2)
  local w = math.abs(self.x1 - x2)
  
  g.setColor(255, 255, 255, 50 * self.alpha)
  g.rectangle('fill', x, -1, w, ctx.hud.v + 2)

  g.setColor(255, 255, 255, 255 * self.alpha)
  g.rectangle('line', x + .5, -1, w, ctx.hud.v + 2)
end

function HudSelector:mousepressed(x, y, b)
  --
end

function HudSelector:mousereleased(x, y, b)
  --
end
