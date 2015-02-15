require 'require'

function love.load()
  config = love.filesystem.load('config.lua')()

  function saveUser(user)
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/user.json', json.encode(user, {indent = true}))
  end

  function saveOptions(options)
    love.filesystem.createDirectory('save')
    love.filesystem.write('save/options.json', json.encode(options, {indent = true}))
  end

	Context:add(Menu)
  --Context:add(Patcher)
end

love.update = Context.update
love.draw = Context.draw
love.quit = Context.quit

love.handlers = setmetatable({}, {__index = Context})
