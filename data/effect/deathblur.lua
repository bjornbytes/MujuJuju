local g = love.graphics
local DeathBlur = {}

function DeathBlur:init()
  self:resize()
	self.amount = 0.1
end

function DeathBlur:update()
  self.active = ctx.ded

	if self.active then
		self.amount = lume.lerp(self.amount, 2, .25 * ls.tickrate)
	end
end

function DeathBlur:applyEffect(source, target)
  self.hblur:send('amount', self.amount / source:getWidth())
  self.vblur:send('amount', self.amount / source:getHeight())
  g.setColor(255, 255, 255)
  for i = 1, 6 do
    g.setShader(self.hblur)
    target:renderTo(function()
      g.draw(source)
    end)

    g.setShader(self.vblur)
    source:renderTo(function()
      g.draw(target)
    end)
  end
end

function DeathBlur:resize()
	self.canvas = love.graphics.newCanvas()
	self.hblur = data.media.shaders.horizontalBlur
  self.vblur = data.media.shaders.verticalBlur
end

return DeathBlur
