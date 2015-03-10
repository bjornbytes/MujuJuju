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
  self.trashTimer = 5
end

function MenuSurvivalDrag:update()
  if self:isDraggingRune() then
    local rune = self.dragging
    local x, y, size = self:snap(love.mouse.getX(), love.mouse.getY(), .05 * ctx.u)
    lerpRune(rune, 'x', x)
    lerpRune(rune, 'y', y)
    lerpRune(rune, 'size', size)
    if math.inside(x, y, unpack(ctx.survival.geometry.runes[#ctx.survival.geometry.runes])) then
      self.trashTimer = self.trashTimer - ls.tickrate
      if self.trashTimer <= 0 then
        ctx.user.runes[self.dragSource][self.dragIndex] = nil
        self.dragging = nil
        self.trashTimer = 5
        saveUser(ctx.user)
        table.clear(ctx.campaign.geometry)
      end
    else
      self.trashTimer = 5
    end
  elseif self:isDraggingMinion() then
    local x, y, size = self:snap(love.mouse.getX(), love.mouse.getY(), 1)
    local minion = self.dragging
    lerpAnimation(minion, 'x', x)
    lerpAnimation(minion, 'y', y)
    lerpAnimation(minion, 'scale', size)
  end

  self.prevDragAlpha = self.dragAlpha
  self.dragAlpha = math.lerp(self.dragAlpha, self.dragging and 1 or 0, math.min(10 * ls.tickrate, 1))
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

    g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * ctx.v, (lerpd.size - .015 * ctx.v) * .5, table.has(ctx.rewards.runes, rune))

    if self.trashTimer < 5 then
      local trash = math.ceil(self.trashTimer)
      g.setColor(255, 0, 0)
      g.setFont('mesmerize', (.08 + .02 * (5 - trash)) * v)
      g.printShadow(trash, lerpd.x, lerpd.y, true)
    end
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
    local scale = (2 * r / cw) * lerpd.scale * 3
    g.setColor(255, 255, 255)
    g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, scale, scale, cw / 2, ch / 2)
  end
end

function MenuSurvivalDrag:mousepressed(mx, my, b)
  if b ~= 'l' and b ~= 'r' then return end

  -- Rune Stash
  local runes = ctx.survival.geometry.runes
  for i = 1, #runes do
    local rune = ctx.user.runes.stash[i]
    local x, y, w, h = unpack(runes[i])
    if b == 'l' and i ~= #runes and rune and math.inside(mx, my, x, y, w, h) then
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
      if b == 'l' then
        self.dragging = minion
        self.dragIndex = i
        self.dragSource = 'deck'
      elseif b == 'r' then
        table.insert(ctx.survival.gutter, minion)
        ctx.user.survival.minions[i] = nil
        ctx.survival:refreshGutter()
      end
    end

    if minion then
      for j = 1, #runes do
        local rune = ctx.user.runes[minion][j]
        if b == 'l' and rune and math.inside(mx, my, unpack(runes[j])) then
          self.dragging = rune
          self.dragIndex = j
          self.dragSource = minion
        end
      end
    end
  end

  -- Gutter
  local gutter = ctx.survival.geometry.gutter
  for i = 1, #gutter do
    local minion = ctx.survival.gutter[i]
    local x, y, r, runes = unpack(ctx.survival.geometry.gutter[i])
    if b == 'l' and minion and math.insideCircle(mx, my, x, y, r) then
      self.dragging = minion
      self.dragIndex = i
      self.dragSource = 'gutter'
    end

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      if b == 'l' and rune and math.inside(mx, my, unpack(runes[j])) then
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
    if i ~= 33 and self:isDraggingRune() and math.inside(mx, my, unpack(geometry[i])) then
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
      if minion and self:isDraggingRune() and math.inside(mx, my, unpack(runes[j])) then
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
    ctx.survival:refreshGutter()
    saveUser(ctx.user)
    table.clear(ctx.survival.geometry)
  end

  self.dragging = nil
  self.trashTimer = 5
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
  if self:isDraggingRune() then
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
  end

  -- Deck
  local deck = ctx.survival.geometry.deck
  for i = 1, #deck do
    local minion = ctx.user.survival.minions[i]
    local x, y, r, runes = unpack(deck[i])
    if self:isDraggingMinion() then
      local dis = math.distance(x, y, mx, my)
      if dis < mindis then
        minx, miny, mindis, minsize = x, y, dis, .9
      end
    elseif minion and self:isDraggingRune() then
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
  end

  -- Gutter
  local gutter = ctx.survival.geometry.gutter
  for i = 1, #gutter do
    local minion = ctx.survival.gutter[i]
    local x, y, r, runes = unpack(ctx.survival.geometry.gutter[i])
    if self:isDraggingMinion() then
      local dis = math.distance(x, y, mx, my)
      if dis < mindis then
        minx, miny, mindis, minsize = x, y, dis, .5
      end
    elseif self:isDraggingRune() then
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
  end

  local threshold = self:isDraggingMinion() and (.1 * v) or (.05 * v)
  if mindis < threshold then
    return math.lerp(mx, minx, .5), math.lerp(my, miny, .5), math.lerp(size, minsize, .5)
  end

  return mx, my, size
end
