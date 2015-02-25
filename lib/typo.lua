Typo = {}
Typo.fonts = {}
local setFont = love.graphics and love.graphics.setFont

Typo.font = function(name, size)
  if not love.graphics then return nil end
  size = math.round(size)

  if name == 'mesmerize' then name = 'rawengulk' end

  if not name then
    Typo.fonts.default[size] = Typo.fonts.default[size] or love.graphics.newFont(size)
    return Typo.fonts.default[size]
  end

  if Typo.fonts[name] and Typo.fonts[name][size] then return Typo.fonts[name][size] end
  Typo.fonts[name] = Typo.fonts[name] or setmetatable({}, {__mode = 'v'})
  Typo.fonts[name][size] = Typo.fonts[name][size] or love.graphics.newFont('media/fonts/' .. name .. '.ttf', size)
  return Typo.fonts[name][size]
end

if love.graphics then
  love.graphics.setFont = function(name, size)
    if type(name) ~= 'string' then
      setFont(name)
    else
      setFont(Typo.font(name, size))
    end

    return love.graphics.getFont()
  end
end

Typo.resize = function()
  table.clear(Typo.fonts)
end
