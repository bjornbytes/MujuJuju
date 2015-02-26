Shrujus = extend(Manager)
Shrujus.manages = 'shruju'

function Shrujus:init()
  Manager.init(self)
end

function Shrujus:update()
  self.ct = self.ct or 0
  if tick % ls.tickrate == 0 and self.ct < 2 then --love.math.random() < .002 then
    self.ct = self.ct + 1
    self:add(data.shruju[love.math.random(1, #data.shruju)], {x = love.math.random(ctx.map.width)})
  end

  Manager.update(self)
end
