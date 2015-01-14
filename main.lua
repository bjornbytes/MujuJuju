require 'require'

function love.load()
  config = love.filesystem.load('config.lua')()

  function saveUser(user)
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(user))
  end

	Context:add(Menu)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
