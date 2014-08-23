Minion = class()

Minion.width = 20
Minion.height = 20

Minion.maxHealth = 70
Minion.speed = 10

Minion.fireRate = .8

function Minion:init(data)
	self.target = nil
	self.fireTimer = 0
	self.y = love.graphics.getHeight() - ctx.environment.groundHeight - self.height

	table.merge(data, self)
end

function Minion:update()
	--
end

function Minion:draw()
	--
end
