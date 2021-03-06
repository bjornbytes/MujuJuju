local g = love.graphics
MenuSurvival = class()

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = math.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * ls.tickrate, 1))
end

local function lerpRune(rune, key, val)
  ctx.survival.prevRuneTransforms[rune][key] = ctx.survival.runeTransforms[rune][key]
  ctx.survival.runeTransforms[rune][key] = math.lerp(ctx.survival.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuSurvival:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    minionFrame = function()
      local u, v = ctx.u, ctx.v
      return {.07 * u - v * .02, .07 * u - v * .04, self.geometry.runesFrame[3], .5 * v}
    end,

    gutter = function()
      local u, v = love.graphics.getDimensions()
      local r = .06 * v
      local inc = (r * 2) + .08 * u
      local frame = self.geometry.runesFrame
      local ct = #self.gutter
      local x = frame[1] + frame[3] / 2 - inc * ((ct - 1) / 2)
      local y = .12 * v
      local runeSize = .035 * u
      local runeInc = runeSize + .01 * v
      local runey = y + .09 * v
      local res = {}
      for i = 1, ct do
        table.insert(res, {x, y, r, {}})

        local runex = x - (runeInc * (3 - 1) / 2)
        for j = 1, 3 do
          table.insert(res[i][4], {runex - runeSize / 2, runey - runeSize / 2, runeSize, runeSize})
          runex = runex + runeInc
        end

        x = x + inc
      end
      return res
    end,

    deck = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.minionFrame
      local size = .08 * u
      local inc = size + .12 * u
      local runeSize = .045 * u
      local runeInc = runeSize + .02 * v
      local x = frame[1] + frame[3] / 2 - (inc * .5)
      local y = .39 * v
      local runey = y + .15 * v
      local res = {}
      for i = 1, 2 do
        res[i] = {x, y, size / 2, {}}

        local runex = x - (runeInc * (3 - 1) / 2)
        for j = 1, 3 do
          table.insert(res[i][4], {runex - runeSize / 2, runey - runeSize / 2, runeSize, runeSize})
          runex = runex + runeInc
        end

        x = x + inc
      end

      return res
    end,

    runes = function()
      local u, v = ctx.u, ctx.v
      local size = .045 * u
      local inc = size + .01 * v
      local x = u * .07
      local ox = x
      local y = v * .675
      local res = {}
      for i = 1, 33 do
        table.insert(res, {math.round(x), math.round(y), size, size})
        x = x + inc
        if i % 11 == 0 then y = y + inc x = ox end
      end
      return res
    end,

    runesLabel = function()
      local u, v = ctx.u, ctx.v
      return {u * .07, v * .675 - v * .015 - v * .04}
    end,

    runesFrame = function()
      local u, v = ctx.u, ctx.v
      local label = self.geometry.runesLabel
      local x = label[1] - v * .02
      local y = label[2] - v * .01
      local w = ((self.geometry.runes[1][4] + .01 * v) * 11) + v * .03
      local h = ((self.geometry.runes[1][4] + .01 * v) * 3) + v * .055 + v * .02
      return {x, y, w, h}
    end,

    play = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.runesFrame
      local w, h = .2 * u, .13 * v
      local midx = (u + frame[1] + frame[3]) / 2
      return {midx - w / 2, .45 * v, w, h}
    end,

    muju = function()
      local u, v = ctx.u, ctx.v
      local x, y = u * .72, v * .8
      local res = {x, y, {}}
      local hats = ctx.user.hats or {}
      local hatSize = .04 * v
      local hatInc = hatSize + .08 * v
      local hatX = x + .12 * u
      local hatY = .77 * v
      for i = 1, math.min(#hats, 4) do
        table.insert(res[3], {hatX, hatY, hatSize})
        hatX = hatX + hatInc
        if i % 2 == 0 then
          hatX = x + .12 * u
          hatY = hatY + hatInc
        end
      end

      return res
    end,

    hatsFrame = function()
      local u, v = ctx.u, ctx.v
      local x, y = unpack(self.geometry.muju)
      local hatSize = .04 * v
      local hatInc = hatSize + .08 * v
      local hatX = x + .12 * u
      local hatY = .77 * v
      local padding = .04 * v
      return {hatX - hatSize / 2 - padding, hatY - hatSize / 2 - padding, 2 * padding + 2 * hatSize + .08 * v, 2 * padding + 2 * hatSize + .08 * v}
    end
  }

  self.play = ctx.gooey:add(Button, 'menu.survival.play')
  self.play.geometry = function() return self.geometry.play end
  self.play:on('click', function() ctx.animations.muju:set('death') end)
  self.play.text = 'Play'

  self.drag = MenuSurvivalDrag()
end

function MenuSurvival:activate()
  table.clear(self.geometry)

  -- Initialize runes
  self.runeTransforms = {}
  self.prevRuneTransforms = {}
  table.each(ctx.user.runes, function(list)
    table.each(list, function(rune)
      self.runeTransforms[rune] = {}
      self.prevRuneTransforms[rune] = {}
    end)
  end)

  self.hatHoverFactors = {}
  self.prevHatHoverFactors = {}

  self.drag.active = true

  self:refreshGutter()
end

function MenuSurvival:deactivate()
  self.drag.active = false
end

function MenuSurvival:update()
  if not self.active then return end

  local mx, my = love.mouse.getPosition()

  local runes = self.geometry.runes
  for i = 1, 33 do
    local rune = ctx.user.runes.stash[i]
    if rune and not self.drag:isDraggingRune('stash', i) then
      local x, y, w, h = unpack(runes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)
      lerpRune(rune, 'size', h)

      if math.inside(mx, my, x, y, w, h) then
        ctx.tooltip:setRuneTooltip(rune)
      end
    end
  end

  local gutter = self.geometry.gutter
  for i = 1, #gutter do
    local x, y, r, runes = unpack(gutter[i])
    local minion = self.gutter[i]

    if not self.drag:isDraggingMinion('gutter', i) then
      lerpAnimation(minion, 'x', x)
      lerpAnimation(minion, 'y', y)
      lerpAnimation(minion, 'scale', .75)
    end

    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      if rune and not self.drag:isDraggingRune(minion, j) then
        local x, y, w, h = unpack(runes[j])

        lerpRune(rune, 'x', x + w / 2)
        lerpRune(rune, 'y', y + h / 2)
        lerpRune(rune, 'size', h)

        if math.inside(mx, my, x, y, w, h) then
          ctx.tooltip:setRuneTooltip(rune)
        end
      end
    end
  end

  local deck = self.geometry.deck
  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])

    local minion = ctx.user.survival.minions[i]
    if minion then
      if not self.drag:isDraggingMinion('deck', i) then
        lerpAnimation(minion, 'x', x)
        lerpAnimation(minion, 'y', y)
        lerpAnimation(minion, 'scale', .9)
      end

      for j = 1, #runes do
        local rune = ctx.user.runes[minion][j]
        if rune and not self.drag:isDraggingRune(minion, j) then
          local x, y, w, h = unpack(runes[j])

          lerpRune(rune, 'x', x + w / 2)
          lerpRune(rune, 'y', y + h / 2)
          lerpRune(rune, 'size', h)

          if math.inside(mx, my, x, y, w, h) then
            ctx.tooltip:setRuneTooltip(rune)
          end
        end
      end
    end
  end

  local _, _, hats = unpack(self.geometry.muju)
  for i = 1, #ctx.user.hats do
    local hat = ctx.user.hats[i]
    if hat and hats[i] then
      local hover = math.insideCircle(mx, my, unpack(hats[i]))
      self.prevHatHoverFactors[hat] = self.hatHoverFactors[hat] or 0
      self.hatHoverFactors[hat] = math.lerp(self.hatHoverFactors[hat] or 0, hover and 1 or 0, math.min(10 * ls.tickrate, 1))
    end
  end

  self.drag:update()
end

function MenuSurvival:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  local ps = love.window.getPixelScale()
  local atlas = data.atlas.hud

  -- Best Time
  local play = self.geometry.play
  local x = play[1] + play[3] / 2
  g.setFont('mesmerize', .08 * v)
  g.setColor(255, 255, 255)
  g.printShadow('Survival', x, .15 * v, true)
  g.setFont('mesmerize', .05 * v)
  local str = 'Best Time:\n' .. toTime(ctx.user.survival.bestTime, true)
  g.setColor(0, 0, 0)
  g.printf(str, x - .2 * u + 1, .26 * v + 1, .4 * u, 'center')
  g.setColor(255, 255, 255)
  g.printf(str, x - .2 * u, .26 * v, .4 * u, 'center')

  -- Rune Frame
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', unpack(self.geometry.runesFrame))

  -- Rune Frames
  g.setColor(255, 255, 255)
  local runes = self.geometry.runes
  for i = 1, #runes do
    local x, y, w, h = unpack(runes[i])
    local scale = w / atlas:getDimensions('frame')
    g.setColor(255, 255, 255)
    g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
  end

  -- Runes
  for i = 1, #runes do
    local x, y, w, h = unpack(runes[i])
    if i == 33 then
      local image = data.media.graphics.menu.trashcan
      local scale = (h - .025 * v) / image:getHeight()
      local dragAlpha = math.lerp(self.drag.prevDragAlpha, self.drag.dragAlpha, ls.accum / ls.tickrate)
      g.setColor(255, 255, 255, 150 + 100 * (self.drag:isDraggingRune() and dragAlpha or 0))
      g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    else
      local rune = ctx.user.runes.stash[i]
      if rune and not self.drag:isDraggingRune('stash', i) then
        local lerpd = {}
        for k, v in pairs(self.runeTransforms[rune]) do
          lerpd[k] = math.lerp(self.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
        end
        lerpd.x = lerpd.x or x
        lerpd.y = lerpd.y or y
        lerpd.size = lerpd.size or h
        h = lerpd.size
        g.setColor(255, 255, 255)
        g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * v, (lerpd.size - .015 * v) * .5, table.has(ctx.rewards.runes, rune))
      end
    end
  end

  -- Rune Label
  g.setColor(255, 255, 255)
  g.setFont('mesmerize', v * .04)
  local x, y = unpack(self.geometry.runesLabel)
  g.print('Runes', x, y)

  -- Minion Gutter
  local gutter = self.geometry.gutter
  for i = 1, #gutter do
    local x, y, r, runes = unpack(gutter[i])
    local minion = self.gutter[i]
    if minion and not self.drag:isDraggingMinion('gutter', i) then
      local cw, ch = ctx.unitCanvas:getDimensions()
      ctx.unitCanvas:clear(0, 0, 0, 0)
      ctx.unitCanvas:renderTo(function()
        ctx.animations[minion]:draw(cw / 2, ch / 2)
      end)
      local lerpd = {}
      for k, v in pairs(ctx.animationTransforms[minion]) do
        lerpd[k] = math.lerp(ctx.prevAnimationTransforms[minion][k] or v, v, ls.accum / ls.tickrate)
      end
      lerpd.x = lerpd.x or x
      lerpd.y = lerpd.y or y
      lerpd.scale = lerpd.scale or .75
      local scale = (2 * r / cw) * lerpd.scale * 3
      g.setColor(255, 255, 255)
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, scale, scale, cw / 2, ch / 2)
    end

    -- Gutter Rune Frames
    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      local scale = w / atlas:getDimensions('frame')
      g.setColor(255, 255, 255)
      g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
    end
  end

  -- Gutter Runes
  for i = 1, #gutter do
    local minion = self.gutter[i]
    local _, _, _, runes = unpack(gutter[i])
    for j = 1, #runes do
      local rune = ctx.user.runes[minion][j]
      local x, y, w, h = unpack(runes[j])
      if rune and not self.drag:isDraggingRune(minion, j) then
        local lerpd = {}
        for k, v in pairs(self.runeTransforms[rune]) do
          lerpd[k] = math.lerp(self.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
        end
        lerpd.x = lerpd.x or x
        lerpd.y = lerpd.y or y
        lerpd.size = lerpd.size or h
        g.setColor(255, 255, 255)
        g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * v, (lerpd.size - .015 * v) * .5, table.has(ctx.rewards.runes, rune))
      end
    end
  end

  -- Deck
  local deck = self.geometry.deck
  for i = 1, #deck do
    local minion = ctx.user.survival.minions[i]
    local x, y, r, runes = unpack(deck[i])

    local xoff = .02 * v
    local height = .04 * v
    g.setColor(0, 0, 0, 100)
    g.polygon('fill', x - r - xoff, y + r - height, x + r + xoff, y + r - height, x + r, y + r, x - r, y + r)

    -- Deck Minion
    if minion and not self.drag:isDraggingMinion('deck', i) then
      local cw, ch = ctx.unitCanvas:getDimensions()
      ctx.unitCanvas:clear(0, 0, 0, 0)
      ctx.unitCanvas:renderTo(function()
        ctx.animations[minion]:draw(cw / 2, ch / 2)
      end)
      local lerpd = {}
      for k, v in pairs(ctx.animationTransforms[minion]) do
        lerpd[k] = math.lerp(ctx.prevAnimationTransforms[minion][k] or v, v, ls.accum / ls.tickrate)
      end
      lerpd.x = lerpd.x or x
      lerpd.y = lerpd.y or y
      lerpd.scale = lerpd.scale or .75
      local scale = (2 * r / cw) * lerpd.scale * 3
      g.setColor(255, 255, 255)
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, scale, scale, cw / 2, ch / 2)
    end

    -- Deck Rune Frames
    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      local scale = w / atlas:getDimensions('frame')
      g.setColor(255, 255, 255)
      g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
    end
  end

  -- Deck Runes
  for i = 1, #deck do
    local minion = ctx.user.survival.minions[i]
    if minion then
      local _, _, _, runes = unpack(deck[i])
      for i = 1, #runes do
        local rune = ctx.user.runes[minion][i]
        if rune and not self.drag:isDraggingRune(minion, i) then
          local x, y, w, h = unpack(runes[i])

          local lerpd = {}
          for k, v in pairs(ctx.survival.runeTransforms[rune]) do
            lerpd[k] = math.lerp(ctx.survival.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
          end
          lerpd.x = lerpd.x or x
          lerpd.y = lerpd.y or y
          lerpd.size = lerpd.size or h
          g.setColor(255, 255, 255)
          g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * v, (lerpd.size - .015 * v) * .5, table.has(ctx.rewards.runes, rune))
        end
      end
    end
  end

  -- Muju
  local color = ctx.user and ctx.user.color or 'purple'
  local animation = ctx.animations.muju

  -- Muju Robe Color
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = animation.spine.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = unpack(config.player.colors[color])
  end

  -- Muju Hat
  animation.spine.skeleton:setSkin(ctx.user.hat or 'santa')
  animation.spine.skeleton:findSlot('hat').a = ctx.user.hat and 1 or 0
  animation.spine.skeleton:findBone('hat').scaleX = animation.scale
  animation.spine.skeleton:findBone('hat').scaleY = animation.scale

  -- Draw Muju
  local cw, ch = ctx.unitCanvas:getDimensions()
  ctx.unitCanvas:clear(0, 0, 0, 0)
  ctx.unitCanvas:renderTo(function()
    animation:draw(cw / 2, ch / 2)
  end)
  local scale = (.15 * v / cw) * 1 * 3
  g.setColor(255, 255, 255)
  local x, y, hats = unpack(self.geometry.muju)
  g.draw(ctx.unitCanvas, x, y, 0, scale, scale, cw / 2, ch / 2)

  -- Hats Frame
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', unpack(self.geometry.hatsFrame))

  -- Hats
  for i = 1, #hats do
    local hat = ctx.user.hats[i]
    if hat then
      local image = data.media.graphics.hats[hat]
      if image then
        local x, y, r = unpack(hats[i])
        local scale = r * 2 / math.max(image:getWidth(), image:getHeight())
        local factor = math.lerp(self.prevHatHoverFactors[hat], self.hatHoverFactors[hat], ls.accum / ls.tickrate)
        scale = scale * (.8 + .2 * factor)
        g.setColor(255, 255, 255, 120 + (130 * (ctx.user.hat == hat and 1 or 0)))
        g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      end
    end
  end

  -- Modules
  self.play:draw()
  self.drag:draw()
end

function MenuSurvival:keyreleased(key)
  if not self.active then return end
  if key == 'escape' then
    ctx:setPage('start')
    return true
  end
end

function MenuSurvival:mousepressed(mx, my, b)
  if not self.active then return end
  self.drag:mousepressed(mx, my, b)
end

function MenuSurvival:mousereleased(mx, my, b)
  if not self.active then return end
  if ctx.optionsPane.active then return end
  self.drag:mousereleased(mx, my, b)

  local _, _, hats = unpack(self.geometry.muju)
  for i = 1, #hats do
    local hat = ctx.user.hats[i]
    if hat then
      local x, y, r = unpack(hats[i])
      if math.insideCircle(mx, my, x, y, r) then
        if b == 'l' then
          ctx.user.hat = hat
        elseif b == 'r' then
          ctx.user.hat = nil
        end

        saveUser(ctx.user)
      end
    end
  end
end

function MenuSurvival:gamepadpressed(gamepad, button)
  if not self.active then return end
  if button == 'dpleft' then self:previousBiome()
  elseif button == 'dpright' then self:nextBiome()
  elseif button == 'start' then ctx.animations.muju:set('death')
  elseif button == 'b' then
    ctx.page = 'start'
    ctx.start.active = true
  end
end

function MenuSurvival:resize()
  table.clear(self.geometry)
end

function MenuSurvival:setBiome(biome)
  self.biome = biome
  ctx:refreshBackground()
end

function MenuSurvival:mujuDead()
  local deck = ctx.user.survival.minions
  if not deck[1] and not deck[2] then return end
  if not deck[1] and deck[2] then table.remove(deck, 1) end
  if #deck >= 3 then return end
  ctx:startGame({mode = 'survival', biome = config.biomeOrder[love.math.random(1, #config.biomeOrder)]})
end

function MenuSurvival:refreshGutter()
  self.gutter = {config.biomes[config.biomeOrder[1]].minion}

  for i = 1, #config.biomeOrder do
    local biome = config.biomeOrder[i]
    local nextBiome = config.biomeOrder[i + 1]
    if nextBiome then
      local minion = config.biomes[nextBiome].minion
      if minion and ctx.user.campaign.medals[biome].silver then
        table.insert(self.gutter, minion)
      end
    end
  end

  local i = 1
  while i <= #self.gutter do
    if table.has(ctx.user.survival.minions, self.gutter[i]) then
      table.remove(self.gutter, i)
    else
      i = i + 1
    end
  end
  table.clear(self.geometry)
end
