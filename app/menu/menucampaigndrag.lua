local g = love.graphics
MenuCampaignDrag = class()

local function lerpRune(rune, key, val)
  ctx.campaign.prevRuneTransforms[rune][key] = ctx.campaign.runeTransforms[rune][key]
  ctx.campaign.runeTransforms[rune][key] = math.lerp(ctx.campaign.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuCampaignDrag:init()
  self.active = false
  self.focused = false
  self.dragging = nil
  self.draggingIndex = nil
end

function MenuCampaignDrag:update()
  if not self.active then return end

  if self.dragging then
    local rune = self.dragging == 'equippedRune' and ctx.user.deck.runes[self.draggingIndex[1]][self.draggingIndex[2]] or ctx.user.runes[self.draggingIndex]
    lerpRune(rune, 'x', love.mouse.getX())
    lerpRune(rune, 'y', love.mouse.getY())
  end
end

function MenuCampaignDrag:draw()
  if not self.active then return end

  if self.dragging then
    local x, y, w, h
    if self.dragging == 'equippedRune' then
      x, y, w, h = unpack(ctx.campaign.geometry.minion[4][self.draggingIndex[2]])
    else
      x, y, w, h = unpack(ctx.campaign.geometry.runes[self.draggingIndex])
    end
    local rune = self.dragging == 'equippedRune' and ctx.user.deck.runes[self.draggingIndex[1]][self.draggingIndex[2]] or ctx.user.runes[self.draggingIndex]
    local lerpd = {}
    for k, v in pairs(ctx.campaign.runeTransforms[rune]) do
      lerpd[k] = math.lerp(ctx.campaign.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
    end
    g.drawRune(rune, (lerpd.x or x), (lerpd.y or y), h - .02 * ctx.v, h - .05 * ctx.v)
  end
end

function MenuCampaignDrag:mousepressed(mx, my, b)
  do return end
  if b == 'l' then
    local runes = ctx.campaign.geometry.runes
    for i = 1, #runes do
      local x, y, w, h = unpack(runes[i])
      if ctx.user.runes[i] and math.inside(mx, my, x, y, w, h) then
        self.focused = true
        self.dragging = 'rune'
        self.draggingIndex = i
        break
      end
    end
  end

  local x, y, r, runes = unpack(ctx.campaign.geometry.minion)
  for j = 1, #runes do
    local x, y, w, h = unpack(runes[j])
    if ctx.user.deck.runes[1] and ctx.user.deck.runes[1][j] and math.inside(mx, my, x, y, w, h) then
      self.focused = true
      self.dragging = 'equippedRune'
      self.draggingIndex = {1, j}
    end
  end
end

function MenuCampaignDrag:mousereleased(mx, my, b)
  local dirty = false
  do return end

  if self.dragging == 'rune' and b == 'l' then
    local rune = ctx.user.runes[self.draggingIndex]
    if not rune.unit or rune.unit == ctx.user.deck.minions[1] then
      local x, y, r, runes = unpack(ctx.campaign.geometry.minion)

      local i = 1
      for j = 1, #runes do
        local x, y, w, h = unpack(runes[j])
        if math.inside(mx, my, x, y, w, h) then
          if ctx.user.deck.runes[i][j] then
            local index = self.draggingIndex
            ctx.user.runes[index], ctx.user.deck.runes[i][j] = ctx.user.deck.runes[i][j], ctx.user.runes[index]
          else
            ctx.user.deck.runes[i][j] = rune
            table.remove(ctx.user.runes, self.draggingIndex)
          end

          dirty = true
          break
        end
      end
    end
  elseif self.dragging == 'equippedRune' then
    if b == 'r' or (b == 'l' and math.inside(mx, my, unpack(ctx.campaign.geometry.runesFrame))) then
      local i, j = unpack(self.draggingIndex)
      local rune = ctx.user.deck.runes[i][j]
      table.insert(ctx.user.runes, rune)
      ctx.user.deck.runes[i][j] = nil
      dirty = true
    end

    if b == 'l' then
      local i, j = unpack(self.draggingIndex)
      i = 1
      local oldRune = ctx.user.deck.runes[i][j]
      local x, y, r, runes = unpack(ctx.campaign.geometry.minion)
      for n = 1, #runes do
        local x, y, w, h = unpack(runes[n])
        local newRune = ctx.user.deck.runes[m] and ctx.user.deck.runes[m][n]
        if math.inside(mx, my, x, y, w, h) and (not oldRune or not oldRune.unit) and (not newRune or not newRune.unit) then
          ctx.user.deck.runes[i][j], ctx.user.deck.runes[m][n] = ctx.user.deck.runes[m][n], ctx.user.deck.runes[i][j]
          dirty = true
        end
      end
    end
  end

  if dirty then
    saveUser(ctx.user)
    table.clear(ctx.campaign.geometry)
  end

  self.focused = false
  self.dragging = nil
  self.draggingIndex = nil
end

function MenuCampaignDrag:isDragging(kind, index1, index2)
  return self.focused and self.dragging == kind and (self.draggingIndex == index1 or (type(self.draggingIndex) == 'table' and self.draggingIndex[1] == index1 and self.draggingIndex[2] == index2))
end
