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
	g.push()
	g.scale(.25)
	g.draw(source)
	g.pop()
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
		table.each(ctx.particles.particles, function(particle)
			if getmetatable(particle).__index == JujuSex then
				particle:draw()
			end
		end)
	local factor = ctx.player.dead and 1 or 1
  love.graphics.setColor(255, 255, 255, self.alpha * 100 * factor)
  g.setBlendMode('additive')
	g.draw(self.canvas, 0, 0, 0, 4, 4)
	for i = 6, 1, -1 do
		g.draw(self.canvas, 400, 300, 0, 4 + i * 1.25 * factor, 4 + i * 1.25 * factor, self.canvas:getWidth() / 2, self.canvas:getHeight() / 2)
	end
  g.setBlendMode('alpha')

	if ctx.player.dead then
		ctx.player.ghost:draw()
		table.each(ctx.jujus.jujus, function(juju) juju:draw() end)
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
