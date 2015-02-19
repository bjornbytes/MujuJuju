local g = love.graphics
MenuMain = class()

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = math.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * ls.tickrate, 1))
end

local function lerpRune(rune, key, val)
  ctx.prevRuneTransforms[rune][key] = ctx.runeTransforms[rune][key]
  ctx.runeTransforms[rune][key] = math.lerp(ctx.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuMain:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    deck = function()
      local u, v = love.graphics.getDimensions()
      local size = .2 * v
      local inc = size + .15 * v
      local runeSize = .08 * v
      local runeInc = runeSize + .02 * v
      local frame = self.geometry.gutterRunesFrame
      local x = frame[1] + frame[3] / 2 - inc * ((#ctx.user.deck.minions - 1) / 2)
      local y = .45 * v
      local runey = y - .18 * v
      local res = {}
      for i = 1, #ctx.user.deck.minions do
        table.insert(res, {x, y, size / 2, {}})
        local runex = x - (runeInc * (3 - 1) / 2)
        for i = 1, 3 do
          table.insert(res[#res][4], {runex - runeSize / 2, runey - runeSize / 2, runeSize, runeSize})
          runex = runex + runeInc
        end
        x = x + inc
      end
      return res
    end,

    gutterRunes = function()
      local u, v = love.graphics.getDimensions()
      local size = .08 * v
      local inc = size + .01 * v
      local x = u * .19
      local ox = x
      local y = v * .675
      local res = {}
      for i = 1, 21 do
        table.insert(res, {math.round(x), math.round(y), size, size})
        x = x + inc
        if i % 7 == 0 then y = y + inc x = ox end
      end
      return res
    end,

    gutterRunesLabel = function()
      local u, v = ctx.u, ctx.v
      return {u * .19, v * .675 - v * .015 - v * .04}
    end,

    gutterRunesFrame = function()
      local u, v = ctx.u, ctx.v
      local label = self.geometry.gutterRunesLabel
      local x = label[1] - v * .02
      local y = label[2] - v * .01
      local w = ((self.geometry.gutterRunes[1][4] + .01 * v) * 7) + v * .03
      local h = v * .34
      return {x, y, w, h}
    end,

    gutterMinions = function()
      local u, v = love.graphics.getDimensions()
      local r = .06 * v
      local inc = (r * 2) + .02 * v
      local frame = self.geometry.gutterRunesFrame
      local x = frame[1] + frame[3] / 2 - inc * ((#ctx.user.minions - 1) / 2)
      local y = .15 * v
      local res = {}
      for i = 1, #ctx.user.minions do
        table.insert(res, {x, y, r})
        x = x + inc
      end
      return res
    end,

    map = function()
      local u, v = love.graphics.getDimensions()
      local width = .4 * v
      local height = width * (10 / 16)
      local x = u * .8
      local y = .22 * v
      return {x - width / 2, y, width, height}
    end,

    play = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.gutterRunesFrame
      local w, h = .2 * u, .13 * v
      local midx = (.6 + (.4 / 2)) * u
      return {midx - w / 2, frame[2] + frame[4] - h, w, h}
    end
  }

  self.selectedBiome = selectedBiome or 1

  self.play = ctx.gooey:add(Button, 'menu.main.play')
  self.play.geometry = function() return self.geometry.play end
  self.play:on('click', function() ctx.animations.muju:set('death') end)
  self.play.text = 'Play'

  self.map = MenuMap()
  self.drag = MenuDrag()
end

function MenuMain:update()
  self.active = ctx.page == 'main'

  self.map:update()
  if not self.active or self.map.active then return end

  local mx, my = love.mouse.getPosition()
  local u, v = ctx.u, ctx.v

  local deck = self.geometry.deck
  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])

    if not self.drag:isDragging('minion', i) then
      local code = ctx.user.deck.minions[i]

      lerpAnimation(code, 'scale', .9)
      lerpAnimation(code, 'x', x)
      lerpAnimation(code, 'y', y)

      if math.insideCircle(mx, my, x, y, r) then
        ctx.tooltip:setUnitTooltip(code)
      end
    end

    for j = 1, #runes do
      if ctx.user.deck.runes[i] and ctx.user.deck.runes[i][j] then
        local rune = ctx.user.deck.runes[i][j]
        if not self.drag:isDragging('rune', i, j) then
          local x, y, w, h = unpack(runes[j])
          lerpRune(rune, 'x', x + w / 2)
          lerpRune(rune, 'y', y + h / 2)
        end

        if math.inside(mx, my, unpack(runes[j])) then
          ctx.tooltip:setRuneTooltip(ctx.user.deck.runes[i][j])
        end
      end
    end
  end

  local gutterMinions = self.geometry.gutterMinions
  for i = 1, #gutterMinions do
    if not self.drag:isDragging('gutterMinion', i) then
      local code = ctx.user.minions[i]
      local x, y, r = unpack(gutterMinions[i])

      lerpAnimation(code, 'scale', .5)
      lerpAnimation(code, 'x', x)
      lerpAnimation(code, 'y', y)
    end
  end

  local gutterRunes = self.geometry.gutterRunes
  for i = 1, #gutterRunes do
    if ctx.user.runes[i] and not self.drag:isDragging('gutterRune', i) then
      local rune = ctx.user.runes[i]
      local x, y, w, h = unpack(gutterRunes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)

      if math.inside(mx, my, unpack(gutterRunes[i])) then
        ctx.tooltip:setRuneTooltip(ctx.user.runes[i])
        break
      end
    end
  end

  self.drag:update()
end

function MenuMain:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  local ps = love.window.getPixelScale()

  local detailsAlpha = 255
  local biome = config.biomeOrder[self.selectedBiome]
  local x, y, w, h = unpack(self.geometry.map)
  g.setFont('mesmerize', .06 * v)
  g.setColor(0, 0, 0, detailsAlpha)
  g.printCenter(config.biomes[biome].name, x + w / 2 + 1, .15 * v + 1)
  g.setColor(255, 255, 255, detailsAlpha)
  g.printCenter(config.biomes[biome].name, x + w / 2, .15 * v)

  local medalSize = v * .03
  local medalInc = (medalSize * 2 + (v * .02))
  local medalX = x + w / 2 - medalInc * (3 - 1) / 2
  local medalY = y + h + medalSize + (v * .05)
  for i, benchmark in ipairs({'bronze', 'silver', 'gold'}) do
    local achieved = ctx.user.highscores[biome] >= config.biomes[biome].benchmarks[benchmark]
    g.setColor(255, 255, 255, (achieved and 1 or .4) * detailsAlpha)
    local image = data.media.graphics.menu[benchmark]
    local scale = medalSize * 2 / image:getWidth() * (achieved and 1 or .8)
    g.draw(image, medalX, medalY, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    medalX = medalX + medalInc
  end

  local minutes = math.floor((ctx.user.highscores[biome] or 0) / 60)
  local seconds = ctx.user.highscores[biome] % 60
  local time = string.format('%02d:%02d', minutes, seconds)
  g.setFont('mesmerize', .04 * v)
  g.setColor(0, 0, 0, detailsAlpha)
  g.printf('Best Time ' .. time, x + w / 2 - 100 + 1, medalY + medalSize + v * .04 + 1, 200, 'center')
  g.setColor(255, 255, 255, detailsAlpha)
  g.printf('Best Time ' .. time, x + w / 2 - 100, medalY + medalSize + v * .04, 200, 'center')

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', unpack(self.geometry.gutterRunesFrame))

  -- Gutter rune frames
  g.setColor(255, 255, 255)
  local gutterRunes = self.geometry.gutterRunes
  for i = 1, #gutterRunes do
    local x, y, w, h = unpack(gutterRunes[i])
    local rune = ctx.user.runes[i]
    local image = data.media.graphics.hud.frame
    local scale = w / image:getWidth()
    g.setColor(255, 255, 255)
    g.draw(image, x, y, 0, scale, scale)
  end

  -- Gutter runes
  for i = 1, #gutterRunes do
    local x, y, w, h = unpack(gutterRunes[i])
    local rune = ctx.user.runes[i]
    if rune and not self.drag:isDragging('gutterRune', i) then
      local lerpd = {}
      for k, v in pairs(ctx.runeTransforms[rune]) do
        lerpd[k] = math.lerp(ctx.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
      end
      g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .04 * v)
    end
  end

  g.setColor(255, 255, 255)
  g.setFont('mesmerize', v * .04)
  local x, y = unpack(self.geometry.gutterRunesLabel)
  g.print('Runes', x, y)

  local frame = self.geometry.gutterRunesFrame
  g.setFont('mesmerize', .016 * v)
  g.setColor(#ctx.user.deck.minions < ctx.user.deckSlots and {255, 255, 255} or {255, 150, 150})
  g.printShadow(#ctx.user.deck.minions .. ' / ' .. ctx.user.deckSlots, frame[1] + frame[3] / 2, v * .04, true)

  local gutterMinions = self.geometry.gutterMinions
  for i = 1, #gutterMinions do
    local code = ctx.user.minions[i]
    local x, y, r = unpack(gutterMinions[i])

    if not self.drag:isDragging('gutterMinion', i) then
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
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, lerpd.scale * ps, lerpd.scale * ps, cw / 2, ch / 2)
    end
  end

  local deck = self.geometry.deck
  g.setColor(255, 255, 255)
  for i = 1, #deck do
    local code = ctx.user.deck.minions[i]
    local x, y, r, runes = unpack(deck[i])

    -- Stage
    g.setColor(0, 0, 0, 100)
    local xoff = .02 * v
    local height = .04 * v
    g.polygon('fill', x - r - xoff, y + r - height, x + r + xoff, y + r - height, x + r, y + r, x - r, y + r)

    if not self.drag:isDragging('minion', i) then
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
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, lerpd.scale * ps, lerpd.scale * ps, cw / 2, ch / 2)
    end

    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      local rune = ctx.user.deck.runes[i] and ctx.user.deck.runes[i][j]
      local image = data.media.graphics.hud.frame
      local scale = w / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, x, y, 0, scale, scale)
    end
  end

  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])

    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])

      if ctx.user.deck.runes[i] and ctx.user.deck.runes[i][j] and not self.drag:isDragging('rune', i, j) then
        local rune = ctx.user.deck.runes[i][j]
        local lerpd = {}
        for k, v in pairs(ctx.runeTransforms[rune]) do
          lerpd[k] = math.lerp(ctx.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
        end

        g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .04 * v)
      end
    end
  end

  self.play:draw()
  self.map:draw()
  self.drag:draw()
end

function MenuMain:keypressed(key)
  return self.map:keypressed(key)
end

function MenuMain:mousepressed(mx, my, b)
  self.map:mousepressed(mx, my, b)

  if not self.active or self.map.active then return end

  self.drag:mousepressed(mx, my, b)
end

function MenuMain:mousereleased(mx, my, b)
  if not self.active or self.map.active then return end
  if ctx.optionsPane.active then return end
  self.drag:mousereleased(mx, my, b)
end

function MenuMain:gamepadpressed(gamepad, button)
  if not self.active or self.map.active then return end
  if button == 'dpleft' then self:previousBiome()
  elseif button == 'dpright' then self:nextBiome()
  elseif button == 'start' then ctx.animations.muju:set('death')
  elseif button == 'b' then
    ctx.page = 'start'
    ctx.start.active = true
    ctx.start.alpha = 1
  end
end

function MenuMain:resize()
  self.map:resize()
  table.clear(self.geometry)
end

function MenuMain:previousBiome()
  self:setBiome(self.selectedBiome - 1)
end

function MenuMain:nextBiome()
  self:setBiome(self.selectedBiome + 1)
end

function MenuMain:setBiome(index)
  if index == 0 then index = #config.biomeOrder
  elseif index > #config.biomeOrder then index = 1 end
  self.selectedBiome = index
  ctx:refreshBackground()
end
