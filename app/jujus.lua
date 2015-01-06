Jujus = class()
Jujus.depth = -6

function Jujus:init()
	self.jujus = {}
  ctx.event:emit('view.register', {object = self})
end

function Jujus:update()
  table.with(self.jujus, 'update')
end

function Jujus:draw()
  table.with(self.jujus, 'draw')
end

function Jujus:add(data)
	local juju = Juju(data)
	self.jujus[juju] = juju
end

function Jujus:remove(juju)
	ctx.view:unregister(juju)
	self.jujus[juju] = nil
end
