local g = love.graphics
MenuCampaignDrag = class()

local function lerpRune(rune, key, val)
  ctx.campaign.prevRuneTransforms[rune][key] = ctx.campaign.runeTransforms[rune][key]
  ctx.campaign.runeTransforms[rune][key] = math.lerp(ctx.campaign.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuCampaignDrag:init()
  self.dragging = nil
  self.dragIndex = nil
  self.dragSource = nil
  self.dragAlpha = 0
  self.prevDragAlpha = self.dragAlpha
end

function MenuCampaignDrag:update()
  local rune = self.dragging
  if rune then
    local x, y = self:snap(love.mouse.getPosition())
    lerpRune(rune, 'x', x)
    lerpRune(rune, 'y', y)
    lerpRune(rune, 'scale', 1.1)
  end

  self.prevDragAlpha = self.dragAlpha
  self.dragAlpha = math.lerp(self.dragAlpha, rune and 1 or 0, math.min(10 * ls.tickrate, 1))
end

function MenuCampaignDrag:draw()
  local rune, index, source = self.dragging, self.dragIndex, self.dragSource
  if rune then
    local x, y, w, h
    if source == 'stash' then
      x, y, w, h = unpack(ctx.campaign.geometry.runes[index])
    else
      x, y, w, h = unpack(ctx.campaign.geometry.minion[4][index])
    end

    local lerpd = {}
    for k, v in pairs(ctx.campaign.runeTransforms[rune]) do
      lerpd[k] = math.lerp(ctx.campaign.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
    end

    h = h * lerpd.scale
    g.drawRune(rune, (lerpd.x or x), (lerpd.y or y), h - .02 * ctx.v, h - .05 * ctx.v)
  end
end

function MenuCampaignDrag:mousepressed(mx, my, b)
  if b ~= 'l' then return end

  local runes = ctx.campaign.geometry.runes
  for i = 1, #runes do
    local rune = ctx.user.runes.stash[i]
    local x, y, w, h = unpack(runes[i])
    if rune and math.inside(mx, my, x, y, w, h) then
      self.dragging = rune
      self.dragIndex = i
      self.dragSource = 'stash'
      break
    end
  end

  local _, _, _, runes = unpack(ctx.campaign.geometry.minion)
  local minion = config.biomes[ctx.campaign.biome].minion
  for i = 1, #runes do
    local rune = ctx.user.runes[minion][i]
    local x, y, w, h = unpack(runes[i])
    if rune and math.inside(mx, my, x, y, w, h) then
      self.dragging = rune
      self.dragIndex = i
      self.dragSource = minion
    end
  end
end

function MenuCampaignDrag:mousereleased(mx, my, b)
  if not self.dragging or b ~= 'l' then return end

  mx, my = self:snap(mx, my)

  local dirty = false
  local runes = ctx.user.runes
  local dragging, index, source = self.dragging, self.dragIndex, self.dragSource
  local minion = config.biomes[ctx.campaign.biome].minion

  local function swap(src1, idx1, src2, idx2)
    local old, new = runes[src1][idx1]
    local unit1, unit2 = old and old.unit, new and new.unit
    if (unit1 and (src2 ~= 'stash' and src2 ~= unit1)) or (unit2 and (src1 ~= 'stash' and src1 ~= unit2)) then return end
    runes[src1][idx1], runes[src2][idx2] = runes[src2][idx2], runes[src1][idx1]
  end

  -- Stash
  local geometry = ctx.campaign.geometry.runes
  for i = 1, 33 do
    local rune = ctx.user.runes.stash[i]
    if math.inside(mx, my, unpack(geometry[i])) then
      swap(source, index, 'stash', i)
      dirty = true
      break
    end
  end

  -- Minion
  local geometry = ctx.campaign.geometry.minion[4]
  for i = 1, 3 do
    local rune = ctx.user.runes[minion][i]
    if math.inside(mx, my, unpack(geometry[i])) then
      swap(source, index, minion, i)
      dirty = true
      break
    end
  end

  if dirty then
    saveUser(ctx.user)
    table.clear(ctx.campaign.geometry)
  end

  self.dragging = nil
end

function MenuCampaignDrag:isDragging(source, index)
  return self.dragging and self.dragIndex == index and self.dragSource == source
end

function MenuCampaignDrag:snap(mx, my)
  local minx, miny, mindis = nil, nil, math.huge
  local minion = config.biomes[ctx.campaign.biome].minion
  local v = ctx.v

  -- Stash
  local geometry = ctx.campaign.geometry.runes
  for i = 1, 33 do
    local rune = ctx.user.runes.stash[i]
    local x, y, w, h = unpack(geometry[i])
    x, y = x + w / 2, y + h / 2
    local dis = math.distance(x, y, mx, my)
    if dis < mindis then
      minx, miny, mindis = x, y, dis
    end
  end

  -- Minion
  local geometry = ctx.campaign.geometry.minion[4]
  for i = 1, 3 do
    local rune = ctx.user.runes[minion][i]
    local x, y, w, h = unpack(geometry[i])
    x, y = x + w / 2, y + h / 2
    local dis = math.distance(x, y, mx, my)
    if dis < mindis then
      minx, miny, mindis = x, y, dis
    end
  end

  if mindis < .05 * v then
    return math.lerp(mx, minx, .3), math.lerp(my, miny, .3)
  end

  return mx, my
end
