require 'require'

function love.load()
  data.load()
  config = love.filesystem.load('config.lua')()

  for stat in pairs({'damage', 'health'}) do
    local rune = {
      stat = stat,
      flat = something,
      scaling = something, -- per minute
      ability = 'code' -- which ability does this rune benefit
    }
  end

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
