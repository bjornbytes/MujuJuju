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
      local inc = (r * 2) + .06 * u
      local frame = self.geometry.runesFrame
      local ct = #self.gutter
      local x = frame[1] + frame[3] / 2 - inc * ((ct - 1) / 2)
      local y = .12 * v
      local res = {}
      for i = 1, ct do
        table.insert(res, {x, y, r})
        x = x + inc
      end
      return res
    end,

    deck = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.minionFrame
      local size = .1 * u
      local inc = size + .12 * u
      local runeSize = .045 * u
      local runeInc = runeSize + .02 * v
      local x = frame[1] + frame[3] / 2 - (inc * .5)
      local y = .38 * v
      local runey = y + .16 * v
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
      return {midx - w / 2, .07 * u - .02 * v, w, h}
    end,

    muju = function()
      local u, v = ctx.u, ctx.v
      return {u * .75, v * .8}
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
    if rune and not self.drag:isDragging('stash', i) then
      local x, y, w, h = unpack(runes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)
      lerpRune(rune, 'scale', 1)

      if math.inside(mx, my, x, y, w, h) then
        ctx.tooltip:setRuneTooltip(rune)
      end
    end
  end

  local gutter = self.geometry.gutter
  for i = 1, #gutter do
    local x, y, r, runes = unpack(gutter[i])
    local minion = self.gutter[i]
    if minion then
      lerpAnimation(minion, 'x', x)
      lerpAnimation(minion, 'y', y)
      lerpAnimation(minion, 'scale', .75)
    end
  end

  local deck = self.geometry.deck
  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])

    local minion = ctx.user.survival.minions[i]
    if minion then
      lerpAnimation(minion, 'x', x)
      lerpAnimation(minion, 'y', y)
      lerpAnimation(minion, 'scale', .9)
    end
  end

  self.drag:update()
end

function MenuSurvival:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  local ps = love.window.getPixelScale()
  local atlas = data.atlas.hud

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
    local rune = ctx.user.runes.stash[i]
    if rune and not self.drag:isDragging('stash', i) then
      local lerpd = {}
      for k, v in pairs(self.runeTransforms[rune]) do
        lerpd[k] = math.lerp(self.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
      end
      h = h * lerpd.scale
      g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .05 * v)
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
    if minion then
      local cw, ch = ctx.unitCanvas:getDimensions()
      ctx.unitCanvas:clear(0, 0, 0, 0)
      ctx.unitCanvas:renderTo(function()
        ctx.animations[minion]:draw(cw / 2, ch / 2)
      end)
      local lerpd = {}
      for k, v in pairs(ctx.animationTransforms[minion]) do
        lerpd[k] = math.lerp(ctx.prevAnimationTransforms[k] or v, v, ls.accum / ls.tickrate)
      end
      local scale = (2 * r / cw) * lerpd.scale * 3 * ps
      g.setColor(255, 255, 255)
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, scale, scale, cw / 2, ch / 2)
    end
    --[[for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      local scale = w / atlas:getDimensions('frame')
      g.setColor(255, 255, 255)
      g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
    end]]
  end

  local deck = self.geometry.deck
  for i = 1, #deck do
    local x, y, r, runes = unpack(deck[i])

      local xoff = .02 * v
      local height = .04 * v
      g.setColor(0, 0, 0, 100)
      g.polygon('fill', x - r - xoff, y + r - height, x + r + xoff, y + r - height, x + r, y + r, x - r, y + r)

    local minion = ctx.user.survival.minions[i]
    if minion then
      local cw, ch = ctx.unitCanvas:getDimensions()
      ctx.unitCanvas:clear(0, 0, 0, 0)
      ctx.unitCanvas:renderTo(function()
        ctx.animations[minion]:draw(cw / 2, ch / 2)
      end)
      local lerpd = {}
      for k, v in pairs(ctx.animationTransforms[minion]) do
        lerpd[k] = math.lerp(ctx.prevAnimationTransforms[k] or v, v, ls.accum / ls.tickrate)
      end
      local scale = (2 * r / cw) * lerpd.scale * 3 * ps
      g.setColor(255, 255, 255)
      g.draw(ctx.unitCanvas, lerpd.x, lerpd.y, 0, scale, scale, cw / 2, ch / 2)
    end

    for j = 1, #runes do
      local x, y, w, h = unpack(runes[j])
      local scale = w / atlas:getDimensions('frame')
      g.setColor(255, 255, 255)
      g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
    end
  end

  -- Muju
  local color = ctx.user and ctx.user.color or 'purple'
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = ctx.animations.muju.spine.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = unpack(config.player.colors[color])
  end
  g.setColor(255, 255, 255)
  g.push()
  g.translate(unpack(self.geometry.muju))
  g.scale(MenuOptions.pixelScale)
  ctx.animations.muju:draw(0, 0)
  g.pop()

  -- Modules
  self.play:draw()
  self.drag:draw()
end

function MenuSurvival:keypressed(key)
  --
end

function MenuSurvival:mousepressed(mx, my, b)
  if not self.active then return end
  self.drag:mousepressed(mx, my, b)
end

function MenuSurvival:mousereleased(mx, my, b)
  if not self.active then return end
  if ctx.optionsPane.active then return end
  self.drag:mousereleased(mx, my, b)
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
  ctx:startGame({mode = 'survival', biome = 'forest'})
end

function MenuSurvival:refreshGutter()
  self.gutter = table.copy(config.starters)
  local i = 1
  while i <= #self.gutter do
    if table.has(ctx.user.survival.minions, self.gutter[i]) then
      table.remove(self.gutter, i)
    else
      i = i + 1
    end
  end
end