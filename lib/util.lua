timer = {}
timer.rot = function(v, fn)
	if v > 0 then
		v = v - tickRate
		if v <= 0 then
			v = 0
			v = f.exe(fn) or 0
		end
	end
	return v
end

function isa(instance, class)
  return getmetatable(instance).__index == class
end

function math.insideCircle(x, y, cx, cy, r)
  return math.distance(x, y, cx, cy) < r
end

function toTime(x, format)
  x = math.floor(x)
  local seconds = math.floor(x % 60)
  local minutes = math.floor(x / 60)
  if format then
    if minutes < 10 then minutes = '0' .. minutes end
  end
  if seconds < 10 then seconds = '0' .. seconds end
  return minutes .. ':' .. seconds
end

if love.graphics then
  local g = love.graphics
  function g.printCenter(what, x, y)
    local font = g.getFont()
    g.print(what, x, y, 0, 1, 1, math.round(font:getWidth(what) / 2), math.round(font:getHeight(what) / 2))
  end

  function g.printShadow(what, x, y, center)
    local f = center and g.printCenter or g.print
    local color = {g.getColor()}
    g.setColor(0, 0, 0, color[4])
    f(what, x + 1, y + 1)
    g.setColor(color)
    f(what, x, y)
  end

  function g.drawRune(rune, x, y, stoneSize, runeSize)
    if not rune then return end

    -- Stone
    local image = data.media.graphics.runes['bg' .. rune.background:capitalize()]
    local scale = stoneSize / image:getHeight()
    g.setColor(255, 255, 255)
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    -- Rune
    local image = data.media.graphics.runes[rune.image]
    local scale = runeSize / image:getHeight()
    g.setColor(config.runes.colors[rune.color])
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  end
end
