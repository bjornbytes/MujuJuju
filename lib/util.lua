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
end
