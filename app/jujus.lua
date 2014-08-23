Jujus = class()

function Jujus:init()
	self.jujus = {}
end

function Jujus:update()
	table.with(self.jujus, 'update')
end

function Jujus:add(data)
	local juju = Juju(data)
	self.jujus[juju] = juju
end

function Jujus:remove(juju)
	ctx.view:unregister(juju)
	self.jujus[juju] = nil
end
