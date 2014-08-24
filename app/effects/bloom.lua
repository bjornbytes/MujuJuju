Bloom = {}

local g = love.graphics

function Bloom:init()
  self:resize()
	self.alpha = .1
end

function Bloom:update()
  self.alpha = math.lerp(self.alpha, ctx.player.dead and .9 or .1, .6 * tickRate)
end

function Bloom:applyEffect(source, target)
  g.setCanvas(self.canvas)
	g.draw(source, 0, 0, 0, .25, .25)
  self.hblur:send('amount', .005)
  self.vblur:send('amount', .005)
  g.setColor(255, 255, 255)
  for i = 1, 6 do
    g.setShader(self.hblur)
    self.working:renderTo(function()
      g.draw(self.canvas)
    end)
    g.setShader(self.vblur)
    self.canvas:renderTo(function()
      g.draw(self.working)
    end)
  end

  g.setShader()
  g.setCanvas(target)
  g.draw(source)
  love.graphics.setColor(255, 255, 255, self.alpha * 255)
  g.setBlendMode('additive')
	for i = 1, 3 do
		g.draw(self.canvas, 0, 0, 0, 4, 4)
		g.draw(self.canvas, 400, 300, 0, 4 + i, 4 + i, 400, 300)
	end
  g.setBlendMode('alpha')

	if ctx.player.dead then
		ctx.player.ghost:draw()
	end

  g.setCanvas()

  self.canvas:clear()
  self.working:clear()
end

function Bloom:resize()
  local w, h = g.getDimensions()
  self.canvas = g.newCanvas(w / 4, h / 4)
  self.working = g.newCanvas(w / 4, h / 4)
	self.threshold = love.graphics.newShader('media/shaders/threshold.shader')
	self.hblur = love.graphics.newShader('media/shaders/horizontalBlur.shader')
	self.vblur = love.graphics.newShader('media/shaders/verticalBlur.shader')
end
