require 'require'

function love.load()
	print(math.sin(math.pi / 2))
	Context:add(Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
