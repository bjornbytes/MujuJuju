local popo = require 'lib/deps/popo/Text'
local g = love.graphics
Tutorial = class()

function Tutorial:init()
  self.text = popo('[Welcome to Muju Juju!](ease)', {
    font = g.setFont('mesmerize', .1 * love.graphics.getHeight()),

    easeInit = function(c)
      c.t = 0
      c.targetx = c.x
      c.targety = c.y
    end,

    ease = function(dt, c)
      c.t = c.t + dt
      local direction = c.position
      local threshold = math.clamp((c.t - (.02 * c.position)) / .4, 0, 1) ^ 2
      local distance = 50 * (1 - threshold)
      local alpha = threshold ^ 2
      g.setColor(255, 255, 255, 255 * alpha)
      c.x = c.targetx + math.dx(distance, direction)
      c.y = c.targety + math.dy(distance, direction)
    end
  })
end

function Tutorial:draw()
  local u, v = love.graphics.getDimensions()
  local font = self.text.font

  g.setColor(0, 0, 0)
  g.rectangle('fill', 0, 0, u, v)

  g.setColor(255, 255, 255)
  self.text:update(delta)
  self.text:draw(u * .5 - font:getWidth(self.text.str_text) / 2, v * .5)
end

function Tutorial:keypressed(key)
  table.each(self.text.characters, function(c)
    c.t = 0
  end)
end
