JujuJuices = class()

function JujuJuices:init()
	self.jujuJuices = {}
end

function JujuJuices:update()
	table.with(self.jujuJuices, 'update')
end

function JujuJuices:add(data)
	local jujuJuice = JujuJuice(data)
	self.jujuJuices[jujuJuice] = jujuJuice
end

function JujuJuices:remove(jujuJuice)
	ctx.view:unregister(jujuJuice)
	self.jujuJuices[jujuJuice] = nil
end