local Bloom = {}

local g = love.graphics

function Bloom:init()
  self:resize()
	self.alpha = 0
end

function Bloom:update()
  local p = ctx.player
  local alphas = config.biomes[ctx.biome].effects.bloom.alpha
  self.alpha = math.lerp(self.alpha, p.dead and alphas[2] or alphas[1], 5 * tickRate)
end

function Bloom:applyEffect(source, target)
  local p = ctx.player
  local w, h = g.getWidth(), g.getHeight()
  local threshold = data.media.shaders.threshold

  if self.alpha < 5 then
    g.setCanvas(target)
    g.draw(source)
    return
  end

  g.setColor(255, 255, 255)
  g.setCanvas(self.canvas)

  threshold:send('threshold', 0.8)
  g.setShader(threshold)
  g.draw(source, 0, 0, 0, .25, .25)

  self.hblur:send('amount', 4 / w)
  self.vblur:send('amount', 4 / h)
  for i = 1, 3 do
    g.setShader(self.hblur)
    g.setCanvas(self.working)
    g.draw(self.canvas)
    g.setShader(self.vblur)
    g.setCanvas(self.canvas)
    g.draw(self.working)
  end

  g.setShader()
  g.setCanvas(target)
  g.draw(source)

  g.setColor(255, 255, 255, self.alpha)
  g.setBlendMode('additive')
	g.draw(self.canvas, 0, 0, 0, 4, 4)
  g.setBlendMode('alpha')
end

function Bloom:resize()
  local w, h = g.getDimensions()
  self.canvas = g.newCanvas(w / 4, h / 4)
  self.working = g.newCanvas(w / 4, h / 4)
	self.threshold = love.graphics.newShader('media/shaders/threshold.shader')
	self.hblur = love.graphics.newShader('media/shaders/horizontalBlur.shader')
	self.vblur = love.graphics.newShader('media/shaders/verticalBlur.shader')
end

return Bloom
