local g = love.graphics
Shruju = class()
Shruju.width = 64
Shruju.height = 64

function Shruju:activate()
  self.timer = config.shruju.lifetime
  self.y = ctx.map.height - ctx.map.groundHeight
  self.animation = data.animation.shruju1()
  self.animation:on('complete', function(data)
    if data.state.name == 'spawn' then self.animation:set('idle') end
  end)

  ctx.event:emit('view.register', {object = self})
end

function Shruju:update()
  self.timer = timer.rot(self.timer, function()
    ctx.shrujus:remove(self)
  end)
end

function Shruju:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Shruju:draw()
  self.animation:draw(self.x, self.y)
end

function Shruju:pickup()
  ctx.player.shruju = self
  self:apply()
  ctx.shrujus:remove(self)
  ctx.event:emit('view.unregister', {object = self})
end

function Shruju:drop()
  self:remove()
  ctx.shrujus.objects[self] = self
  self.x = ctx.player.x
  self.timer = config.shruju.lifetime
  self.animation:set('spawn')
  ctx.event:emit('view.register', {object = self})
end

function Shruju:playerNearby()
  local p = ctx.player
  return not p.dead and math.abs(p.x - self.x) <= self.width / 2 + p.width / 2
end
