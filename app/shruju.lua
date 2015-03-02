local g = love.graphics
Shruju = class()
Shruju.width = 64
Shruju.height = 64
Shruju.depth = -5

function Shruju:activate()
  self.timer = config.shruju.lifetime
  self.y = ctx.map.height - ctx.map.groundHeight
  self.index = love.math.random(1, 5)
  self.animation = data.animation['shruju' .. self.index]()
  self.animation:on('complete', function(data)
    if data.state.name == 'spawn' then self.animation:set('idle') end
  end)

  ctx.event:emit('view.register', {object = self})
end

function Shruju:update()
  self.timer = timer.rot(self.timer, function()
    ctx.shrujus:remove(self)
  end)

  if love.math.random() < 4 * ls.tickrate then
    ctx.particles:emit('magicshruju', self.x, self.y - 30, 1)
  end
end

function Shruju:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Shruju:draw()
  local multiplier = self.timer < 10 and (self.timer < 3 and 6 or 3) or 0
  if math.floor(self.timer * multiplier) % 2 == 0 then
    self.animation:draw(self.x, self.y)
  end
end

function Shruju:pickup()
  ctx.player.shruju = self
  f.exe(self.apply, self)
  ctx.shrujus:remove(self)
  ctx.event:emit('view.unregister', {object = self})
end

function Shruju:drop()
  f.exe(self.remove, self)
  ctx.shrujus.objects[self] = self
  self.x = ctx.player.x
  self.animation:set('spawn')
  ctx.event:emit('view.register', {object = self})
end

function Shruju:playerNearby()
  local p = ctx.player
  return not p.dead and math.abs(p.x - self.x) <= self.width / 2 + p.width / 2
end
