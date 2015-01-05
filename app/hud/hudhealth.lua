HudHealth = class()

local g = love.graphics

local green = {50, 230, 50}
local red = {255, 0, 0}
local purple = {200, 80, 255}
local orange = {255, 185, 40}

local function bar(x, y, hard, soft, color, width, height)
  x, y = ctx.view:screenPoint(x, y)
  width = width * ctx.view.scale

  g.setColor(255, 255, 255)
  local w, h = data.media.graphics.healthbarFrame:getDimensions()
  local scale = width / w
  local xx = math.round(x - width / 2)
  local yy = math.round(y)

  g.draw(data.media.graphics.healthbarFrame, xx, yy, 0, scale, scale)

  xx = xx + math.round(3 * scale)
  yy = yy + math.round(3 * scale)

  local barHeight = data.media.graphics.healthbarGradient:getHeight()
  g.setColor(color[1], color[2], color[3], 200)
  g.draw(data.media.graphics.healthbarBar, xx, yy, 0, hard * math.round(width - 6 * scale), scale)

  if soft then
    g.setColor(color[1], color[2], color[3], 100)
    g.draw(data.media.graphics.healthbarBar, xx, yy, 0, soft * math.round(width - 6 * scale), scale)
  end

  g.setBlendMode('additive')
  g.setColor(255, 255, 255, 180)
	g.draw(data.media.graphics.healthbarGradient, xx, yy, 0, 1 * math.round(width - 6 * scale), scale)
  g.setBlendMode('alpha')
end

local function stack(t, x, range, delta)
	for i = x - range, x + range, 1 do
    t[i] = t[i] and (t[i] + delta) or 1
	end
end

function HudHealth:draw()
  if ctx.ending then return end

  local p = ctx.players:get(ctx.id)
  local vx, vy = math.lerp(ctx.view.prevx, ctx.view.x, tickDelta / tickRate), math.lerp(ctx.view.prevy, ctx.view.y, tickDelta / tickRate)

  ctx.players:each(function(player)
    local x, y, hard, soft = player:getHealthbar()
    local color = (p and player.team == p.team) and green or red
    bar(x, y - 20, hard, soft, color, 100, 3)
  end)

  ctx.shrines:each(function(shrine)
    local color = (p and shrine.team == p.team) and green or red
    local x, y, hard, soft = shrine:getHealthbar()
    local w, h = 120 + (60 * (shrine.hurtFactor)), 4 + (1 * shrine.hurtFactor)
    bar(x, y - 65, hard, soft, color, w, h)
  end)

  local t = {}
  ctx.units:each(function(unit)
    local x, y, hard, soft = unit:getHealthbar()
    local eliteBuffs = unit.buffs:buffsWithTag('elite')
    local location = math.floor(unit.x)
    stack(t, location, unit.width, 2)

    if next(eliteBuffs) then
      local string = ''
      table.each(eliteBuffs, function(buff)
        string = string .. buff.name .. ' '
      end)
      g.setFont('pixel', 8)
      g.setColor(0, 0, 0)
      g.printCenter(string, x + 1, (y - 30 - 5 * t[location]) - 12 + 1)
      g.setColor(255, 255, 255)
      g.printCenter(string, x, (y - 30 - 5 * t[location]) - 12)
    end

    local color = (p and unit.team == p.team) and green or red
    bar(x, y - 30 - 5 * t[location], hard, soft, color, 80, 3)
  end)
end
