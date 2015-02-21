local g = love.graphics
Jujus = class()
Jujus.depth = -6

function Jujus:init()
	self.jujus = {}
  self.spriteBatch = g.newSpriteBatch(data.media.graphics.juju, 256, 'stream')
  if not ctx.effects:get('vignette') then ctx.event:emit('view.register', {object = self}) end
end

function Jujus:update()
  table.with(self.jujus, 'update')
end

function Jujus:draw()
  self.spriteBatch:clear()
  self.spriteBatch:bind()
  table.with(self.jujus, 'draw')
  self.spriteBatch:unbind()
  g.draw(self.spriteBatch)
end

function Jujus:add(data)
	local juju = Juju(data)
	self.jujus[juju] = juju
end

function Jujus:remove(juju)
	ctx.view:unregister(juju)
	self.jujus[juju] = nil
end

function Jujus:clear()
  table.each(self.jujus, function(juju)
    self:remove(juju)
  end)
end
