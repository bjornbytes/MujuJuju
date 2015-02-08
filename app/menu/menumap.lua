local g = love.graphics
local tween = require 'lib/deps/tween/tween'

MenuMap = class()

function MenuMap:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    frame = function()
      local u, v = ctx.u, ctx.v
      local factor = self.factor
      local width = math.lerp(.4 * v, .8 * u, factor)
      local height = width * (10 / 16)
      local x = math.lerp(u * .8, u * .5, factor)
      local y = math.lerp(.35 * v, v * .5, factor)
      return {x - width / 2, y - height / 2, width, height}
    end
  }

  self.active = false
  self.factor = 0
  self.tweenDuration = .5
  self.tweenMethod = 'inOutBack'
  self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)
end

function MenuMap:update()

end

function MenuMap:draw()
  self.tween:update(delta)

  local u, v = ctx.u, ctx.v

  if self.tween.clock < self.tweenDuration then
    table.clear(self.geometry)
  end

  -- Fade out background
  --[[g.setColor(0, 0, 0, 180 * math.clamp(self.factor, 0, 1))
  g.rectangle('fill', 0, 0, u, v)]]

  g.setColor(0, 0, 0, 200)
  g.rectangle('fill', unpack(self.geometry.frame))
end

function MenuMap:toggle()
  if self.tween.clock < self.tweenDuration then return end
  if self.active then
    self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)
  else
    self.tween = tween.new(self.tweenDuration, self, {factor = 1}, self.tweenMethod)
  end
  self.active = not self.active
end
