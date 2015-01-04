Map = class()

local g = love.graphics

Map.width, Map.height = 1067, 600
Map.depth = -100

function Map:init()
  self.groundHeight = 92

  self.spiritAlpha = 0

  if ctx.view then
    ctx.view.xmax = self.width
    ctx.view.ymax = self.height
    ctx.view.x = self.width / 2 - ctx.view.width / 2
  end
  
  self.background = {
    depth = 10,
    draw = function()
      local image = data.media.graphics.map[ctx.biome]
      local scale = self.height / image:getHeight()
      g.setColor(255, 255, 255)
      g.draw(image, 0 * scale, 0 * scale, 0, scale, scale)

      local alpha = self.spiritAlpha * 255
      local p = ctx.players:get(ctx.id)
      alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)
      g.setColor(255, 255, 255, alpha)
      g.draw(data.media.graphics.map[ctx.biome .. 'Spirit'], 0 * scale, 0 * scale, 0, scale, scale)
    end
  }

  self.foreground = {
    depth = -50,
    draw = function()
      local image = data.media.graphics.grass
      g.setColor(200, 200, 200)
      g.draw(image, 0, 32)
      local alpha = self.spiritAlpha * 255
      local p = ctx.players:get(ctx.id)
      alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)
      g.setColor(200, 200, 200, alpha)
      g.draw(data.media.graphics.spiritGrass, 0, 32)
    end
  }

  ctx.event:emit('view.register', {object = self.background})
  ctx.event:emit('view.register', {object = self.foreground})
end

function Map:update()
  self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.players:get(ctx.id).dead and 1 or 0, .6 * tickRate)
end

function Foreground:init()
	self.grass = love.graphics.newImage('media/graphics/grass.png')
	self.spiritGrass = love.graphics.newImage('media/graphics/spiritGrass.png')
	self.spiritAlpha = 0
	ctx.view:register(self)
end

function Foreground:update()
	self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.player.dead and 1 or 0, .6 * tickRate)
end

function Foreground:draw()
	local g = love.graphics

	g.setColor(200, 200, 200)
	g.draw(self.grass, 0, 32)

	local alpha = self.spiritAlpha * 255
	alpha = math.lerp(alpha, (1 - (ctx.player.healthDisplay / ctx.player.maxHealth)) * 255, .5)
	g.setColor(200, 200, 200, alpha)
	g.draw(self.spiritGrass, 0, 32)
end
