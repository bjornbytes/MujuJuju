Shrujus = extend(Manager)
Shrujus.manages = 'shruju'

function Shrujus:init()
  Manager.init(self)
end

function Shrujus:update()
  if tick % math.floor(1 / ls.tickrate) == 0 and love.math.random() < .0002 then
    self:add(data.shruju[love.math.random(1, #data.shruju)], {x = love.math.random(ctx.map.width)})
  end

  Manager.update(self)
end
