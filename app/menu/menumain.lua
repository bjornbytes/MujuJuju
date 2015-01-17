local g = love.graphics
local tween = require 'lib/deps/tween/tween'
MenuMain = class()

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = math.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * tickRate, 1))
end

local function lerpRune(rune, key, val)
  ctx.prevRuneTransforms[rune][key] = ctx.runeTransforms[rune][key]
  ctx.runeTransforms[rune][key] = math.lerp(ctx.runeTransforms[rune][key] or val, val, math.min(10 * tickRate, 1))
end

function MenuMain:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    deck = function()
      local u, v = love.graphics.getDimensions()
      local size = .25 * v
      local inc = size + .2 * v
      local runeSize = .08 * v
      local runeInc = runeSize + .02 * v
      local x = u * .5 - inc * ((#ctx.user.deck.minions - 1) / 2)
      local y = .35 * v
      local runey = y - .2 * v
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
        table.insert(res, {x, y, size, size})
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
      local w = u * .36 + v * .02
      local h = v * .34
      return {x, y, w, h}
    end,

    gutterMinions = function()
      local u, v = love.graphics.getDimensions()
      local r = .06 * v
      local inc = (r * 2) + .02 * v
      local x = u * .09
      local y = inc
      local res = {}
      for i = 1, #ctx.user.minions do
        table.insert(res, {x, y, r})
        y = y + inc
      end
      return res
    end,

    biomes = function()
      local u, v = love.graphics.getDimensions()
      local biomeDisplay = math.lerp(self.prevBiomeDisplay, self.biomeDisplay, tickDelta / tickRate)
      local width = .3 * v
      local height = width * .75
      local inc = width + .1 * v
      local x = u * .8
      local y = .25 * v
      local res = {}
      for i = 1, #config.biomeOrder do
        local offset = (inc * (biomeDisplay - i))
        local yoffset = (inc * (biomeDisplay - i) ^ 4)
        table.insert(res, {x - width / 2 - offset, y + yoffset, width, height})
      end
      return res
    end,

    biomeArrows = function()
      local u, v = love.graphics.getDimensions()
      local image = data.media.graphics.menu.arrow
      local scale = v * .04 / image:getWidth()
      local w = .3 * v
      local h = w * .75
      local x = u * .8 - w / 2
      local y = .25 * v
      return {{x - v * .06, y + h / 2}, {x + w + v * .06, y + h / 2}}
    end,

    play = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.gutterRunesFrame
      local w, h = .2 * u, .13 * v
      local midx = (.6 + (.4 / 2)) * u
      return {midx - w / 2, frame[2] + frame[4] / 2 - h / 2, w, h}
    end
  }

  self.selectedBiome = selectedBiome or 1
  self.biomeDisplay = self.selectedBiome
  self.prevBiomeDisplay = self.biomeDisplay
  self.biomeArrowScales = {}
  self.prevBiomeArrowScales = {}

  self.drag = MenuDrag()
end

function MenuMain:update()
  self.active = ctx.page == 'main'

  if not self.active then return end

  local mx, my = love.mouse.getPosition()
  local u, v = ctx.u, ctx.v

  self.prevBiomeDisplay = self.biomeDisplay
  self.biomeDisplay = math.lerp(self.biomeDisplay, self.selectedBiome, math.min(10 * tickRate, 1))
  if math.abs(self.biomeDisplay - self.selectedBiome) > .001 then self.geometry.biomes = nil end

  local deck = self.geometry.deck
  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])

    if not self.drag:isDragging('minion', i) then
      local code = ctx.user.deck.minions[i]

      lerpAnimation(code, 'scale', 1)
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
          break
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

  local image = data.media.graphics.menu.arrow
  local w = v * .04
  for i = 1, 2 do
    self.prevBiomeArrowScales[i] = self.biomeArrowScales[i] or 1
    local x, y = unpack(self.geometry.biomeArrows[i])
    local hover = math.inside(mx, my, x - w / 2, y - w / 2, w, w)
    self.biomeArrowScales[i] = math.lerp(self.biomeArrowScales[i] or 1, hover and 1.5 or 1, 10 * tickRate)
  end

  self.drag:update()
end

function MenuMain:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  --[=[local biomeDisplay = math.lerp(self.prevBiomeDisplay, self.biomeDisplay, tickDelta / tickRate)
  local biomes = self.geometry.biomes
  for i = 1, #biomes do
    local biome = config.biomeOrder[i]
    local unlocked = table.has(ctx.user.biomes, config.biomeOrder[i])
    local x, y, w, h = unpack(biomes[i])
    local alpha = 255 - (math.min(math.abs(biomeDisplay - i), 1.35) * (255 / 1.35))
    if not unlocked then alpha = alpha * .5 end
    if self.selectedBiome == i then g.setColor(255, 255, 255, alpha)
    else g.setColor(255, 255, 255, alpha) end
    local image = data.media.graphics.menu[config.biomeOrder[i]]
    local scale = w / image:getWidth()
    g.draw(image, x, y, 0, scale, scale)

    if not unlocked then
      local lockImage = data.media.graphics.menu.lock
      local lockX = x + (w / 2) - (lockImage:getWidth() * scale) / 2
      local lockY = y + (h / 2) - (lockImage:getHeight() * scale) / 2
      if self.selectedBiome == i then g.setColor(255, 255, 255, 255)
      else g.setColor(255, 255, 255, alpha) end
      g.draw(data.media.graphics.menu.lock, lockX, lockY, 0, scale, scale)
    end

    local detailsAlpha = 255 - (math.min(math.abs(biomeDisplay - i), 1) * (255 / 1))
    if detailsAlpha > 1 then
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
    end
  end

  local biomeArrows = self.geometry.biomeArrows
  local image = data.media.graphics.menu.arrow
  local scale = .04 * v / image:getWidth()
  for i = 1, 2 do
    local x, y = unpack(biomeArrows[i])
    local factor = math.lerp(self.prevBiomeArrowScales[i], self.biomeArrowScales[i], tickDelta / tickRate)
    g.setColor(255, 255, 255)
    g.draw(image, x, y, 0, scale * (i == 2 and -1 or 1) * factor, scale * factor, image:getWidth() / 2, image:getHeight() / 2)
  end]=]

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
        lerpd[k] = math.lerp(ctx.prevRuneTransforms[rune][k] or v, v, tickDelta / tickRate)
      end
      g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .04 * v)
    end
  end

  g.setColor(255, 255, 255)
  g.setFont('mesmerize', v * .04)
  local x, y = unpack(self.geometry.gutterRunesLabel)
  g.print('Runes', x, y)

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
        lerpd[k] = math.lerp(ctx.prevAnimationTransforms[code][k] or v, v, tickDelta / tickRate)
      end
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, lerpd.scale, lerpd.scale, cw / 2, ch / 2)
    end
  end

  if #ctx.user.deck.minions >= ctx.user.deckSlots then g.setColor(255, 100, 100)
  else g.setColor(255, 255, 255) end
  g.setFont('mesmerize', .02 * v)
  g.printCenter(#ctx.user.deck.minions .. ' / ' .. ctx.user.deckSlots, u * .5, .04 * v)

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
        lerpd[k] = math.lerp(ctx.prevAnimationTransforms[code][k] or v, v, tickDelta / tickRate)
      end

      g.setColor(255, 255, 255)
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, lerpd.scale, lerpd.scale, cw / 2, ch / 2)
    end

    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      local rune = ctx.user.deck.runes[i] and ctx.user.deck.runes[i][j]
      local image = data.media.graphics.hud.frame
      local scale = w / image:getWidth()
      g.setColor(255, 255, 255)
      g.draw(image, x, y, 0, scale, scale)

      if ctx.user.deck.runes[i] and ctx.user.deck.runes[i][j] and not self.drag:isDragging('rune', i, j) then
        local rune = ctx.user.deck.runes[i][j]
        local lerpd = {}
        for k, v in pairs(ctx.runeTransforms[rune]) do
          lerpd[k] = math.lerp(ctx.prevRuneTransforms[rune][k] or v, v, tickDelta / tickRate)
        end

        g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .04 * v)
      end
    end
  end

  g.setColor(255, 255, 255)
  local x, y, w, h = unpack(self.geometry.play)
  ctx.button:draw('Play', x, y, w, h)

  self.drag:draw()
end

function MenuMain:keypressed(key)
  if not self.active then return end
  if key == 'return' and table.has(ctx.user.biomes, config.biomeOrder[self.selectedBiome]) then
    ctx.animations.muju:set('death')
  elseif key == 'left' then self:previousBiome()
  elseif key == 'right' then self:nextBiome() 
  elseif key == 'x' and love.keyboard.isDown('lctrl') and love.keyboard.isDown('lshift') then
    love.filesystem.remove('save/user.json')
    if ctx.menuSounds then ctx.menuSounds:stop() end
    Menu.started = false
    Context:remove(ctx)
    Context:add(Menu)
  end
end

function MenuMain:mousepressed(mx, my, b)
  if not self.active then return end
  self.drag:mousepressed(mx, my, b)
end

function MenuMain:mousereleased(mx, my, b)
  if not self.active then return end

  if b == 'l' then
    local play = self.geometry.play
    if math.inside(mx, my, unpack(self.geometry.play)) then
      ctx.sound:play('menuClick')
      ctx.animations.muju:set('death')
    end
  end

  self.drag:mousereleased(mx, my, b)
end

function MenuMain:previousBiome()
  self.selectedBiome = self.selectedBiome - 1
  if self.selectedBiome <= 0 then self.selectedBiome = #config.biomeOrder end
  ctx:refreshBackground()
end

function MenuMain:nextBiome()
  self.selectedBiome = self.selectedBiome + 1
  if self.selectedBiome >= #config.biomeOrder + 1 then self.selectedBiome = 1 end
  ctx:refreshBackground()
end