local g = love.graphics
local DeathBlur = {}

function DeathBlur:init()
  self:resize()
	self.amount = 0.1
end

function DeathBlur:update()
	if ctx.ded then
		self.amount = math.lerp(self.amount, 4, .25 * tickRate)
	end
end

function DeathBlur:applyEffect(source, target)
	if ctx.ded then
		self.hblur:send('amount', self.amount * .0008)
		self.vblur:send('amount', self.amount * .0008 * (g.getWidth() / g.getHeight()))
		g.setColor(255, 255, 255)
		for i = 1, 3 do
			g.setShader(self.hblur)
			target:renderTo(function()
				g.draw(source)
			end)

			g.setShader(self.vblur)
			source:renderTo(function()
				g.draw(target)
			end)
		end

		target:renderTo(function()
			g.setColor(0, 0, 0, math.min(self.amount * 120, 120))
			g.rectangle('fill', 0, 0, source:getDimensions())
		end)
  else
    g.setCanvas(target)
    g.draw(source)
    g.setCanvas()
  end
end

function DeathBlur:resize()
	self.canvas = love.graphics.newCanvas()
	self.hblur = data.media.shaders.horizontalBlur
  self.vblur = data.media.shaders.verticalBlur
end

return DeathBlur
