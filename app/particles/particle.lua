Particle = class()

function Particle:init(data)
	table.merge(data, self)
	ctx.view:register(self)
end
