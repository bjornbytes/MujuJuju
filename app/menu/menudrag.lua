local g = love.graphics
MenuDrag = class()
MenuDrag.gutterThreshold = .2

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = math.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * ls.tickrate, 1))
end

local function lerpRune(rune, key, val)
  ctx.main.prevRuneTransforms[rune][key] = ctx.main.runeTransforms[rune][key]
  ctx.main.runeTransforms[rune][key] = math.lerp(ctx.main.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuDrag:init()
  self.active = false
  self.focused = false
  self.dragging = nil
  self.draggingIndex = nil
end

function MenuDrag:update()
  if not self.active then return end

  if self.dragging == 'minion' or self.dragging == 'gutterMinion' then
    local code = self.dragging == 'minion' and ctx.user.deck.minions[self.draggingIndex] or ctx.user.minions[self.draggingIndex]
    lerpAnimation(code, 'scale', love.mouse.getY() < self.gutterThreshold * ctx.v and .75 or 1.2)
    lerpAnimation(code, 'x', love.mouse.getX())
    lerpAnimation(code, 'y', love.mouse.getY())
  elseif self.dragging == 'rune' or self.dragging == 'gutterRune' then
    local rune = self.dragging == 'rune' and ctx.user.deck.runes[self.draggingIndex[1]][self.draggingIndex[2]] or ctx.user.runes[self.draggingIndex]
    lerpRune(rune, 'x', love.mouse.getX())
    lerpRune(rune, 'y', love.mouse.getY())
  end
end

function MenuDrag:draw()
  if not self.active then return end

  if self.dragging == 'gutterRune' or self.dragging == 'rune' then
    local x, y, w, h
    if self.dragging == 'rune' then
      x, y, w, h = unpack(ctx.main.geometry.deck[self.draggingIndex[1]][4][self.draggingIndex[2]])
    else
      x, y, w, h = unpack(ctx.main.geometry.gutterRunes[self.draggingIndex])
    end
    local rune = self.dragging == 'rune' and ctx.user.deck.runes[self.draggingIndex[1]][self.draggingIndex[2]] or ctx.user.runes[self.draggingIndex]
    local lerpd = {}
    for k, v in pairs(ctx.main.runeTransforms[rune]) do
      lerpd[k] = math.lerp(ctx.main.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
    end
    g.drawRune(rune, (lerpd.x or x), (lerpd.y or y), h - .02 * ctx.v, h - .05 * ctx.v)
  elseif self.dragging == 'minion' or self.dragging == 'gutterMinion' then
    local index = self.draggingIndex
    local code = self.dragging == 'minion' and ctx.user.deck.minions[index] or ctx.user.minions[index]
    local cw, ch = ctx.unitCanvas:getDimensions()
    ctx.unitCanvas:clear(0, 0, 0, 0)
    ctx.unitCanvas:renderTo(function()
      ctx.animations[code]:draw(cw / 2, ch / 2)
    end)
    local lerpd = {}
    for k, v in pairs(ctx.animationTransforms[code]) do
      lerpd[k] = math.lerp(ctx.prevAnimationTransforms[code][k] or v, v, ls.accum / ls.tickrate)
    end

    g.setColor(255, 255, 255)
    g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, lerpd.scale, lerpd.scale, cw / 2, ch / 2)
  end
end

function MenuDrag:mousepressed(mx, my, b)
  if b == 'l' then
    local gutterRunes = ctx.main.geometry.gutterRunes
    for i = 1, #gutterRunes do
      local x, y, w, h = unpack(gutterRunes[i])
      if ctx.user.runes[i] and math.inside(mx, my, x, y, w, h) then
        self.focused = true
        self.dragging = 'gutterRune'
        self.draggingIndex = i
        break
      end
    end
  end

  local gutterMinions = ctx.main.geometry.gutterMinions
  for i = 1, #gutterMinions do
    local x, y, r = unpack(gutterMinions[i])
    if math.insideCircle(mx, my, x, y, r) then
      if #ctx.user.deck.minions < ctx.user.deckSlots then
        self.focused = true
        self.dragging = 'gutterMinion'
        self.draggingIndex = i
        break
      else
        lerpAnimation(ctx.user.minions[i], 'scale', 1)
      end
    end
  end

  local deck = ctx.main.geometry.deck
  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])
    if math.insideCircle(mx, my, x, y, r) then
      self.focused = true
      self.dragging = 'minion'
      self.draggingIndex = i
      break
    end

    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      if ctx.user.deck.runes[i] and ctx.user.deck.runes[i][j] and math.inside(mx, my, x, y, w, h) then
        self.focused = true
        self.dragging = 'rune'
        self.draggingIndex = {i, j}
      end
    end
  end
end

function MenuDrag:mousereleased(mx, my, b)
  local dirty = false

  if self.dragging == 'gutterRune' and b == 'l' then
    local deck = ctx.main.geometry.deck
    local rune = ctx.user.runes[self.draggingIndex]
    for i = 1, #deck do
      ctx.user.deck.runes[i] = ctx.user.deck.runes[i] or {}
      if #ctx.user.deck.runes[i] < 3 and (not rune.unit or rune.unit == ctx.user.deck.minions[i]) then
        local x, y, r, runes = unpack(deck[i])

        if math.insideCircle(mx, my, x, y, r) then
          table.insert(ctx.user.deck.runes[i], rune)
          table.remove(ctx.user.runes, self.draggingIndex)
          dirty = true
          break
        end

        for j = 1, #runes do
          local x, y, w, h = unpack(runes[j])
          if math.inside(mx, my, x, y, w, h) then
            ctx.user.deck.runes[i][j] = rune
            table.remove(ctx.user.runes, self.draggingIndex)
            dirty = true
            break
          end
        end
      end
    end
  elseif self.dragging == 'rune' then
    if b == 'r' or (b == 'l' and math.inside(mx, my, unpack(ctx.main.geometry.gutterRunesFrame))) then
      local i, j = unpack(self.draggingIndex)
      local rune = ctx.user.deck.runes[i][j]
      table.insert(ctx.user.runes, rune)
      ctx.user.deck.runes[i][j] = nil
      dirty = true
    end

    if b == 'l' then
      local deck = ctx.main.geometry.deck
      local i, j = unpack(self.draggingIndex)
      for i = 1, #deck do
        local x, y, r, runes = unpack(deck[i])
        for k = 1, #runes do
          local x, y, w, h = unpack(runes[k])
          if math.inside(mx, my, x, y, w, h) and not ctx.user.deck.runes[i][j].unit and not ctx.user.deck.runes[i][k].unit then
            ctx.user.deck.runes[i][j], ctx.user.deck.runes[i][k] = ctx.user.deck.runes[i][k], ctx.user.deck.runes[i][j]
            dirty = true
          end
        end
      end
    end
  elseif self.dragging == 'minion' then
    if b == 'r' or my < self.gutterThreshold * ctx.v then
      local index = self.draggingIndex
      local code = ctx.user.deck.minions[index]
      table.insert(ctx.user.minions, code)
      while ctx.user.deck.runes[index] and #ctx.user.deck.runes[index] > 0 do
        table.insert(ctx.user.runes, ctx.user.deck.runes[index][1])
        table.remove(ctx.user.deck.runes[index], 1)
      end
      ctx.user.deck.runes[index] = nil
      table.remove(ctx.user.deck.minions, index)
      dirty = true
    end
  elseif self.dragging == 'gutterMinion' then
    if b == 'r' or my > self.gutterThreshold * ctx.v then
      local index = self.draggingIndex
      local code = ctx.user.minions[index]
      ctx.animations[code]:set('spawn')
      table.insert(ctx.user.deck.minions, code)
      table.remove(ctx.user.minions, index)
      if #ctx.user.deck.minions > ctx.user.deckSlots then
        table.insert(ctx.user.minions, ctx.user.deck.minions[#ctx.user.deck.minions])
        table.remove(ctx.user.deck.minions, index)
      end
      table.each(ctx.user.deck.runes[index], function(rune, j)
        if rune.unit and rune.unit ~= ctx.user.deck.minions[index] then
          table.insert(ctx.user.runes, rune)
          ctx.user.deck.runes[index][j] = nil
        end
      end)
      dirty = true
    end
  end

  if dirty then
    saveUser(ctx.user)
    table.clear(ctx.main.geometry)
  end

  self.focused = false
  self.dragging = nil
  self.draggingIndex = nil
end

function MenuDrag:isDragging(kind, index1, index2)
  return self.focused and self.dragging == kind and (self.draggingIndex == index1 or (type(self.draggingIndex) == 'table' and self.draggingIndex[1] == index1 and self.draggingIndex[2] == index2))
end
