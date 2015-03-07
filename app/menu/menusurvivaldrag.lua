local g = love.graphics
MenuSurvivalDrag = class()

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = math.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * ls.tickrate, 1))
end

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
  if self:isDraggingRune() then
    local rune = self.dragging
    local x, y, size = self:snap(love.mouse.getX(), love.mouse.getY(), .05 * ctx.u)
    lerpRune(rune, 'x', x)
    lerpRune(rune, 'y', y)
    lerpRune(rune, 'size', size)
  elseif self:isDraggingMinion() then
    local x, y = self:snap(love.mouse.getX(), love.mouse.getY())
    local minion = self.dragging
    lerpAnimation(minion, 'x', x)
    lerpAnimation(minion, 'y', y)
    lerpAnimation(minion, 'scale', 1)
  end

  self.prevDragAlpha = self.dragAlpha
  self.dragAlpha = math.lerp(self.dragAlpha, rune and 1 or 0, math.min(10 * ls.tickrate, 1))
end

function MenuSurvivalDrag:draw()
  local index, source = self.dragIndex, self.dragSource
  local u, v = ctx.u, ctx.v
  local ps = love.window.getPixelScale()
  if self:isDraggingRune() then
    local rune = self.dragging
    local h = ctx.survival.geometry.runes[index][4]
    if table.has(ctx.survival.gutter, self.dragSource) then
      h = ctx.survival.geometry.gutter[1][4][1][4]
    end

    local lerpd = {}
    for k, v in pairs(ctx.survival.runeTransforms[rune]) do
      lerpd[k] = math.lerp(ctx.survival.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
    end

    g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * ctx.v, (lerpd.size - .015 * ctx.v) * .5)
  elseif self:isDraggingMinion() then
    local minion = source == 'gutter' and ctx.survival.gutter[index] or ctx.user.survival.minions[index]
    local r = source == 'gutter' and ctx.survival.geometry.gutter[index][3] or ctx.survival.geometry.deck[index][3]
    local cw, ch = ctx.unitCanvas:getDimensions()
    ctx.unitCanvas:clear(0, 0, 0, 0)
    ctx.unitCanvas:renderTo(function()
      ctx.animations[minion]:draw(cw / 2, ch / 2)
    end)
    local lerpd = {}
    for k, v in pairs(ctx.animationTransforms[minion]) do
      lerpd[k] = math.lerp(ctx.prevAnimationTransforms[minion][k] or v, v, ls.accum / ls.tickrate)
    end
    local scale = (2 * r / cw) * lerpd.scale * 3 * ps
    g.setColor(255, 255, 255)
    g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, scale, scale, cw / 2, ch / 2)
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
      self.dragging = minion
      self.dragIndex = i
      self.dragSource = 'deck'
    end

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      if rune and math.inside(mx, my, unpack(runes[j])) then
        self.dragging = rune
        self.dragIndex = j
        self.dragSource = minion
      end
    end
  end

  -- Gutter
  local gutter = ctx.survival.geometry.gutter
  for i = 1, #gutter do
    local minion = ctx.survival.gutter[i]
    local x, y, r, runes = unpack(ctx.survival.geometry.gutter[i])
    if minion and math.insideCircle(mx, my, x, y, r) then
      self.dragging = minion
      self.dragIndex = i
      self.dragSource = 'gutter'
    end

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      if rune and math.inside(mx, my, unpack(runes[j])) then
        self.dragging = rune
        self.dragIndex = j
        self.dragSource = minion
      end
    end
  end
end

function MenuSurvivalDrag:mousereleased(mx, my, b)
  if not self.dragging or b ~= 'l' then return end

  mx, my = self:snap(mx, my)

  local dirty = false
  local user = ctx.user
  local runes = user.runes
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
    local rune = runes.stash[i]
    if self:isDraggingRune() and math.inside(mx, my, unpack(geometry[i])) then
      swapRune(source, index, 'stash', i)
      dirty = true
      break
    end
  end

  -- Deck
  local deck = ctx.survival.geometry.deck
  for i = 1, #deck do
    local minion = user.survival.minions[i]
    local x, y, r, runes = unpack(deck[i])
    if self:isDraggingMinion() and math.insideCircle(mx, my, x, y, r) then
      if source == 'gutter' then
        ctx.survival.gutter[index], user.survival.minions[i] = user.survival.minions[i], ctx.survival.gutter[index]
      else
        user.survival.minions[index], user.survival.minions[i] = user.survival.minions[i], user.survival.minions[index]
      end
      dirty = true
      break
    end

    for j = 1, #runes do
      if self:isDraggingRune() and math.inside(mx, my, unpack(runes[j])) then
        swapRune(source, index, minion, j)
        dirty = true
        break
      end
    end
  end

  -- Gutter
  local gutter = ctx.survival.geometry.gutter
  for i = 1, #gutter do
    local minion = ctx.survival.gutter[i]
    local x, y, r, runes = unpack(ctx.survival.geometry.gutter[i])
    if self:isDraggingMinion() and math.insideCircle(mx, my, x, y, r) then
      if source == 'gutter' then
        ctx.survival.gutter[index], ctx.survival.gutter[i] = ctx.survival.gutter[i], ctx.survival.gutter[index]
      else
        user.survival.minions[index], ctx.survival.gutter[i] = ctx.survival.gutter[i], user.survival.minions[index]
      end
      dirty = true
      break
    end

    for j = 1, #runes do
      if self:isDraggingRune() and math.inside(mx, my, unpack(runes[j])) then
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
  if not source and not index then return type(self.dragging) == 'table' end
  return type(self.dragging) == 'table' and self.dragIndex == index and self.dragSource == source
end

function MenuSurvivalDrag:isDraggingMinion(source, index)
  if not source and not index then return type(self.dragging) == 'string' end
  return type(self.dragging) == 'string' and self.dragIndex == index and self.dragSource == source
end

function MenuSurvivalDrag:snap(mx, my, size)
  size = size or 0
  local minx, miny, mindis, minsize = nil, nil, math.huge, 0
  local v = ctx.v

  -- Rune Stash
  local geometry = ctx.survival.geometry.runes
  for i = 1, 33 do
    local rune = ctx.user.runes.stash[i]
    local x, y, w, h = unpack(geometry[i])
    x, y = x + w / 2, y + h / 2
    local dis = math.distance(x, y, mx, my)
    if dis < mindis then
      minx, miny, mindis, minsize = x, y, dis, h
    end
  end

  -- Deck
  local deck = ctx.survival.geometry.deck
  for i = 1, #deck do
    local minion = ctx.user.survival.minions[i]
    local x, y, r, runes = unpack(deck[i])

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      local x, y, w, h = unpack(runes[j])
      x, y = x + w / 2, y + h / 2
      local dis = math.distance(x, y, mx, my)
      if dis < mindis then
        minx, miny, mindis, minsize = x, y, dis, h
      end
    end
  end

  -- Gutter
  local gutter = ctx.survival.geometry.gutter
  for i = 1, #gutter do
    local minion = ctx.survival.gutter[i]
    local x, y, r, runes = unpack(ctx.survival.geometry.gutter[i])

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      local x, y, w, h = unpack(runes[j])
      x, y = x + w / 2, y + h / 2
      local dis = math.distance(x, y, mx, my)
      if dis < mindis then
        minx, miny, mindis, minsize = x, y, dis, h
      end
    end
  end

  if mindis < .05 * v then
    return math.lerp(mx, minx, .5), math.lerp(my, miny, .5), math.lerp(size, minsize, .5)
  end

  return mx, my, size
end
