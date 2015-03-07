local g = love.graphics
MenuSurvivalDrag = class()

local function lerpRune(rune, key, val)
  ctx.survival.prevRuneTransforms[rune][key] = ctx.survival.runeTransforms[rune][key]
  ctx.survival.runeTransforms[rune][key] = math.lerp(ctx.survival.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuSurvivalDrag:init()
  self.dragging = nil
  self.dragIndex = nil
  self.dragSource = nil
  self.dragAlpha = 0
  self.prevDragAlpha = self.dragAlpha
end

function MenuSurvivalDrag:update()
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

function MenuSurvivalDrag:draw()
  local rune, index, source = self.dragging, self.dragIndex, self.dragSource
  if rune then
    local x, y, w, h
    if source == 'stash' then
      x, y, w, h = unpack(ctx.survival.geometry.runes[index])
    else
      x, y, w, h = unpack(ctx.survival.geometry.deck[source][index])
    end

    local lerpd = {}
    for k, v in pairs(ctx.survival.runeTransforms[rune]) do
      lerpd[k] = math.lerp(ctx.survival.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
    end

    h = h * lerpd.scale
    g.drawRune(rune, (lerpd.x or x), (lerpd.y or y), h - .02 * ctx.v, h - .05 * ctx.v)
  end
end

function MenuSurvivalDrag:mousepressed(mx, my, b)
  if b ~= 'l' then return end

  -- Rune Stash
  local runes = ctx.survival.geometry.runes
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

  -- Deck
  local deck = ctx.survival.geometry.deck
  for i = 1, #deck do
    local minion = ctx.user.survival.minions[i]
    local x, y, r, runes = unpack(deck[i])
    if minion and math.insideCircle(mx, my, x, y, r) then
    end

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      if rune and math.inside(mx, my, unpack(runes[j])) then
        self.dragging = rune
        self.dragIndex = i
        self.dragSource = minion
      end
    end
  end

  -- Gutter
  local gutter = ctx.survival.geometry.gutter
  for i = 1, #gutter do
    local minion = ctx.survival.gutter[i]
    local x, y, r = unpack(ctx.survival.geometry.gutter[i])
    if math.insideCircle(mx, my, x, y, r) then
      self.dragging = minion
      self.dragIndex = i
      self.dragSource = 'gutter'
    end
  end
end

function MenuSurvivalDrag:mousereleased(mx, my, b)
  if not self.dragging or b ~= 'l' then return end

  mx, my = self:snap(mx, my)

  local dirty = false
  local runes = ctx.user.runes
  local dragging, index, source = self.dragging, self.dragIndex, self.dragSource

  local function swapRune(src1, idx1, src2, idx2)
    local old, new = runes[src1][idx1]
    local unit1, unit2 = old and old.unit, new and new.unit
    if (unit1 and (src2 ~= 'stash' and src2 ~= unit1)) or (unit2 and (src1 ~= 'stash' and src1 ~= unit2)) then return end
    runes[src1][idx1], runes[src2][idx2] = runes[src2][idx2], runes[src1][idx1]
  end

  -- Rune Stash
  local geometry = ctx.survival.geometry.runes
  for i = 1, 33 do
    local rune = ctx.user.runes.stash[i]
    if math.inside(mx, my, unpack(geometry[i])) then
      swapRune(source, index, 'stash', i)
      dirty = true
      break
    end
  end

  -- Deck
  local deck = ctx.survival.geometry.deck
  for i = 1, #deck do
    local minion = ctx.user.survival.minions[i]
    local x, y, r, runes = unpack(deck[i])
    if minion and math.insideCircle(mx, my, x, y, r) then
    end

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      if math.inside(mx, my, unpack(runes[j])) then
        swapRune(source, index, minion, j)
        dirty = true
        break
      end
    end
  end

  if dirty then
    saveUser(ctx.user)
    table.clear(ctx.survival.geometry)
  end

  self.dragging = nil
end

function MenuSurvivalDrag:isDraggingRune(source, index)
  return type(self.dragging) == 'table' and self.dragIndex == index and self.dragSource == source
end

function MenuSurvivalDrag:isDraggingMinion(source, index)
  return type(self.dragging) == 'string' and self.dragIndex == index and self.dragSource == source
end

function MenuSurvivalDrag:snap(mx, my)
  local minx, miny, mindis = nil, nil, math.huge
  local v = ctx.v

  return mx, my
end
