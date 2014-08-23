JujuJuices = class()

function JujuJuices:init()
	self.jujuJuices = {}
end

function JujuJuices:update()
	table.with(self.jujuJuices, 'update')
end

function JujuJuices:add(kind, data)
	local jujuJuice = kind(data)
	self.jujuJuices[jujuJuice] = jujuJuice
end

function JujuJuices:remove(jujuJuice)
	self.jujuJuices[jujuJuice] = nil
end
