timer = {}
timer.rot = function(v, fn)
	if v > 0 then
		v = v - ls.tickrate
		if v <= 0 then
			v = 0
			v = f.exe(fn) or 0
		end
	end
	return v
end

function isa(instance, class)
  return getmetatable(instance) and getmetatable(instance).__index == class
end

function math.insideCircle(x, y, cx, cy, r)
  return lume.distance(x, y, cx, cy) < r
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
    g.print(what, x, y, 0, 1, 1, lume.round(font:getWidth(what) / 2), lume.round(font:getHeight(what) / 2))
  end

  function g.printShadow(what, x, y, center, shadowColor)
    local f = center and g.printCenter or g.print
    local color = {g.getColor()}
    g.setColor(shadowColor or {0, 0, 0, color[4]})
    f(what, x + 1, y + 1)
    g.setColor(color)
    f(what, x, y)
  end

  function g.drawRune(rune, x, y, stoneSize, runeSize, glow)
    if not rune then return end

    local atlas = data.atlas.hud
    local _, _, _, a = g.getColor()
    a = a or 255

    -- Stone
    local quad = 'runeBg' .. rune.background:capitalize()
    local w, h = atlas:getDimensions(quad)
    local scale = stoneSize / h
    g.setColor(255, 255, 255, a)
    g.draw(atlas.texture, atlas.quads[quad], x, y, 0, scale, scale, w / 2, h / 2)

    if glow then
      g.setBlendMode('additive')
      g.setColor(255, 255, 255, 80 * (a / 255))
      g.draw(atlas.texture, atlas.quads[quad], x, y, 0, scale, scale, w / 2, h / 2)
      g.setBlendMode('alpha')
    end

    -- Rune
    local quad = 'rune' .. rune.image
    local w, h = atlas:getDimensions(quad)
    local scale = runeSize / h
    local color = config.runes.colors[rune.color]
    g.setColor(color[1], color[2], color[3], a)
    g.draw(atlas.texture, atlas.quads[quad], x, y, 0, scale, scale, w / 2, h / 2)

    if glow then
      g.setBlendMode('additive')
      g.setColor(255, 255, 255, 80 * (a / 255))
      g.draw(atlas.texture, atlas.quads[quad], x, y, 0, scale, scale, w / 2, h / 2)
      g.setBlendMode('alpha')
    end
  end
end
