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

function math.insideCircle(x, y, cx, cy, r)
  return math.distance(x, y, cx, cy) < r
end

if love.graphics then
  local g = love.graphics
  function g.printCenter(what, x, y)
    local font = g.getFont()
    g.print(what, x, y, 0, 1, 1, math.round(font:getWidth(what) / 2), math.round(font:getHeight(what) / 2))
  end
end
