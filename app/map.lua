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
      local alpha = 255 * self.spiritAlpha
      local p = ctx.player
      alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)

      g.setColor(255, 255, 255)
      local image = data.media.graphics.map[ctx.biome .. 'Background']
      local image = data.media.graphics.map[ctx.biome]
      local scale = self.height / image:getHeight()
      g.draw(image, 0 * scale, 0 * scale, 0, scale, scale)

      g.setColor(255, 255, 255, alpha)
      local image = data.media.graphics.map[ctx.biome .. 'BackgroundSpirit']
      local image = data.media.graphics.map[ctx.biome .. 'Spirit']
      local scale = self.height / image:getHeight()
      g.draw(image, 0 * scale, 0 * scale, 0, scale, scale)
    end
  }

  self.foreground = {
    depth = -50,
    draw = function()
      local image = data.media.graphics.grass
      local scale = self.height / data.media.graphics.map[ctx.biome]:getHeight()
      local shearx = math.sin(tick / 100) * math.cos(tick / 60) ^ 2 * .08
      g.setColor(0, 0, 0, 80)
      g.draw(image, self.width / 2 - 10, self.height, 0, scale * 1, scale * 1.2, image:getWidth() / 2, image:getHeight(), shearx / 2)
      g.setColor(200, 200, 200, 255)
      g.draw(image, self.width / 2, self.height, 0, scale, scale, image:getWidth() / 2, image:getHeight(), shearx)
      local alpha = self.spiritAlpha * 255
      local p = ctx.player
      alpha = math.lerp(alpha, (1 - (p.healthDisplay / p.maxHealth)) * 255, .5)
      g.setColor(200, 200, 200, alpha)
      g.draw(data.media.graphics.spiritGrass, self.width / 2, self.height, 0, scale, scale, image:getWidth() / 2, image:getHeight(), shearx)
    end
  }

  ctx.event:emit('view.register', {object = self.background})
  ctx.event:emit('view.register', {object = self.foreground})
end

function Map:update()
  self.spiritAlpha = math.lerp(self.spiritAlpha, ctx.player.dead and 1 or 0, .6 * ls.tickrate)
end
