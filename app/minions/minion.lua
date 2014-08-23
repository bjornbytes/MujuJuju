Minion = class()

Minion.width = 12
Minion.height = 12

Minion.maxHealth = 100
Minion.speed = 10

function Minion:init(data)
	table.merge(data, self)
end

function Minion:udpate()
	--
end

function Minion:draw()
	--
end
