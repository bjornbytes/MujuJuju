Minions = class()

function Minions:init()
	self.minions = {}
end

function Minions:update()
	table.with(self.minions, 'update')
end

function Minions:add(kind, data)
	local minion = kind(data)
	self.minions[minion] = minion
end

function Minions:remove(minion)
	ctx.view:unregister(minion)
	if ctx.upgrades.muju.harvest then
		local randomNum = love.math.random(10, 45)
		if randomNum <= 20 then
			ctx.jujus:add({amount = randomNum, x = minion.x, y = minion.y, velocity = math.floor(love.math.random(-0.9, 1.9)),speed = love.math.random(1, 15)})
		elseif randomNum > 20 and randomNum <= 30 then
			ctx.jujus:add({amount = randomNum*0.25, x = minion.x, y = minion.y, velocity = -1,speed = love.math.random(1, 25)})
			ctx.jujus:add({amount = randomNum*0.75, x = minion.x, y = minion.y, velocity = 1,speed = love.math.random(1, 25)})
		elseif randomNum > 30 then
			ctx.jujus:add({amount = randomNum*0.15, x = minion.x, y = minion.y, velocity = 1,speed = love.math.random(1, 25)})
			ctx.jujus:add({amount = randomNum*0.35, x = minion.x, y = minion.y, velocity = -1,speed = love.math.random(1, 25)})
			ctx.jujus:add({amount = randomNum*0.50, x = minion.x, y = minion.y, velocity = 0,speed = love.math.random(1, 25)})
		end
	end
	self.minions[minion] = nil
end
