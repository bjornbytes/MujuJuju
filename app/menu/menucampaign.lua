local g = love.graphics
MenuCampaign = class()

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = math.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * ls.tickrate, 1))
end

local function lerpRune(rune, key, val)
  ctx.campaign.prevRuneTransforms[rune][key] = ctx.campaign.runeTransforms[rune][key]
  ctx.campaign.runeTransforms[rune][key] = math.lerp(ctx.campaign.runeTransforms[rune][key] or val, val, math.min(10 * ls.tickrate, 1))
end

function MenuCampaign:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    minionFrame = function()
      local u, v = ctx.u, ctx.v
      return {.07 * u - v * .02, .14 * v, self.geometry.runesFrame[3], .45 * v}
    end,

    minion = function()
      local u, v = ctx.u, ctx.v
      local size = .1125 * u
      local runeSize = .045 * u
      local runeInc = runeSize + .02 * v
      local x = .07 * u + size / 2 + .04 * v
      local y = .35 * v
      local runex = x - (runeInc * (3 - 1) / 2)
      local runey = y + .18 * v
      local res = {x, y, size / 2, {}}
      for i = 1, 3 do
        table.insert(res[4], {runex - runeSize / 2, runey - runeSize / 2, runeSize, runeSize})
        runex = runex + runeInc
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

    map = function()
      local u, v = ctx.u, ctx.v
      local width = .4 * v
      local height = width * (10 / 16)
      local x = u * .8
      local y = .22 * v
      return {x - width / 2, y, width, height}
    end,

    play = function()
      local u, v = ctx.u, ctx.v
      local frame = self.geometry.minionFrame
      local w, h = .2 * u, .13 * v
      local midx = (u + frame[1] + frame[3]) / 2
      return {midx - w / 2, .5 * v, w, h}
    end,

    muju = function()
      local u, v = ctx.u, ctx.v
      return {u * .75, v * .8}
    end
  }

  self.play = ctx.gooey:add(Button, 'menu.campaign.play')
  self.play.geometry = function() return self.geometry.play end
  self.play:on('click', function() ctx.animations.muju:set('death') end)
  self.play.text = 'Play'

  self.map = MenuMap()
  self.drag = MenuCampaignDrag()
end

function MenuCampaign:activate()
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

  self.map.active = true
  self.drag.active = true
end

function MenuCampaign:deactivate()
  self.map.active = false
  self.drag.active = false
end

function MenuCampaign:update()
  if not self.active then return end

  self.map:update()

  if not self.biome then return end

  local mx, my = love.mouse.getPosition()
  local u, v = ctx.u, ctx.v
  local minion = config.biomes[self.biome].minion

  local runes = self.geometry.minion[4]
  for i = 1, 3 do
    local rune = ctx.user.runes[minion][i]
    if rune and not self.drag:isDragging(minion, i) then
      local x, y, w, h = unpack(runes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)
      lerpRune(rune, 'size', h)

      if math.inside(mx, my, x, y, w, h) then
        ctx.tooltip:setRuneTooltip(rune)
      end
    end
  end

  local runes = self.geometry.runes
  for i = 1, 32 do
    local rune = ctx.user.runes.stash[i]
    if rune and not self.drag:isDragging('stash', i) then
      local x, y, w, h = unpack(runes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)
      lerpRune(rune, 'size', h)

      if math.inside(mx, my, x, y, w, h) then
        ctx.tooltip:setRuneTooltip(rune)
      end
    end
  end

  self.drag:update()
end

function MenuCampaign:draw()
  if not self.active then return end

  if not self.biome then
    return self.map:draw()
  end

  local u, v = ctx.u, ctx.v
  local ps = love.window.getPixelScale()
  local atlas = data.atlas.hud
  local minion = config.biomes[self.biome].minion

  local detailsAlpha = 255
  local biome = self.biome
  local midx = self.geometry.play[1] + self.geometry.play[3] / 2
  local medalSize = u * .0225
  local medalInc = (medalSize * 4)
  local medalX = midx - medalInc * (3 - 1) / 2
  local medalY = .2 * v + medalSize
  for i, benchmark in ipairs({'bronze', 'silver', 'gold'}) do
    local achieved = ctx.user.campaign.medals[biome][benchmark]
    g.setColor(255, 255, 255, (achieved and 1 or .4) * detailsAlpha)
    local image = data.media.graphics.menu[benchmark]
    local scale = medalSize * 2 / image:getWidth() * (achieved and 1 or .8)
    g.draw(image, medalX, medalY, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if benchmark == 'bronze' then
      local qw, qh = atlas:getDimensions('runeBgBroken')
      local scale = (medalSize * 2 + (.02 * v) * math.sin(tick / 10) / 8) / qw
      g.setColor(achieved and {255, 255, 255} or {0, 0, 0})
      g.draw(atlas.texture, atlas.quads.runeBgBroken, medalX, medalY + .14 * v, 0, scale, scale, qw / 2, qh / 2)
    elseif benchmark == 'silver' then
      local image = data.media.graphics.hats.santa
      local scale = (medalSize * 2 + (.02 * v) * math.sin(tick / 10) / 8) / image:getWidth()
      g.setColor(achieved and {255, 255, 255} or {0, 0, 0})
      g.draw(image, medalX, medalY + .14 * v, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    elseif benchmark == 'gold' then
      local nextMinions = {
        forest = 'xuju',
        cavern = 'kuju',
        tundra = 'thuju'
      }
      local nextMinion = nextMinions[self.biome]
      if nextMinion then
        local cw, ch = ctx.unitCanvas:getDimensions()
        ctx.unitCanvas:clear(0, 0, 0, 0)
        ctx.unitCanvas:renderTo(function()
          local animation = ctx.animations[nextMinion]
          if not achieved then
            animation.spine.skeleton.r = 0
            animation.spine.skeleton.g = 0
            animation.spine.skeleton.b = 0
          end
          animation:draw(cw / 2, ch / 2)
          animation.spine.skeleton.r = 1
          animation.spine.skeleton.g = 1
          animation.spine.skeleton.b = 1
        end)
        local scale = (.1 * v / cw) * 3
        g.setColor(255, 255, 255)
        g.draw(ctx.unitCanvas, medalX, medalY + .17 * v, 0, scale, scale, cw / 2, ch / 2)
      end
    end

    if not achieved then
      g.setColor(255, 255, 255)
      g.setFont('mesmerize', .05 * v)
      g.printCenter('?', medalX, medalY + .14 * v)
    end

    medalX = medalX + medalInc
  end

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
      g.setColor(255, 255, 255, 150 + 100 * dragAlpha)
      g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    else
      local rune = ctx.user.runes.stash[i]
      if rune and not self.drag:isDragging('stash', i) then
        local lerpd = {}
        for k, v in pairs(ctx.campaign.runeTransforms[rune]) do
          lerpd[k] = math.lerp(ctx.campaign.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
        end
        g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * v, (lerpd.size - .015 * v) * .5)
      end
    end
  end

  -- Rune Label
  g.setColor(255, 255, 255)
  g.setFont('mesmerize', v * .04)
  local x, y = unpack(self.geometry.runesLabel)
  g.print('Runes', x, y)

  -- Minion Frame
  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', unpack(self.geometry.minionFrame))

  -- Minion Text
  local unit = data.unit[minion]
  local x = .07 * u + .2 * u
  local textWidth = self.geometry.minionFrame[1] + self.geometry.minionFrame[3] - x - .02 * v
  g.setColor(255, 255, 255)
  g.setFont('mesmerize', .08 * v)
  g.printShadow(unit.name, x, .16 * v)
  g.setFont('mesmerize', .02 * v)
  g.setColor(0, 0, 0)
  g.printf(unit.description, x + 1, .26 * v + 1, textWidth)
  g.setColor(255, 255, 255)
  g.printf(unit.description, x, .26 * v, textWidth)

  -- Minion Featured
  local _, lines = g.getFont():getWrap(unit.description, textWidth)
  local y = .26 * v + lines * g.getFont():getHeight() + .02 * v
  local height = self.geometry.minionFrame[2] + self.geometry.minionFrame[4] - y - .01 * v
  local h = math.max(height / #unit.featured - .01 * v, 0)
  for i = 1, #unit.featured do
    local qw, qh = atlas:getDimensions('frame')
    local scale = h / qh
    g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)

    local qw, qh = atlas:getDimensions(unit.featured[i][1])
    if qw then
      local scale = (h * .75) / math.max(qw, qh)
      g.draw(atlas.texture, atlas.quads[unit.featured[i][1]], x + h / 2, y + h / 2, 0, scale, scale, qw / 2, qh / 2)
    end

    g.setFont('mesmerize', .02 * v)
    local str = unit.upgrades[unit.featured[i][1]].name .. ': ' .. unit.featured[i][2]
    local textWidth = textWidth - h - .01 * v
    local _, lines = g.getFont():getWrap(str, textWidth)
    local textHeight = g.getFont():getHeight() * lines
    g.setColor(0, 0, 0)
    g.printf(str, x + h + .01 * v + 1, y + h / 2 - textHeight / 2 + 1, textWidth)
    g.setColor(255, 255, 255)
    g.printf(str, x + h + .01 * v, y + h / 2 - textHeight / 2, textWidth)
    y = y + h + .01 * v
  end

  -- Minion Stage
  local x, y, r, runes = unpack(self.geometry.minion)
  if true or v / u < 3 / 4 then
    local xoff = .02 * v
    local height = .04 * v
    g.setColor(0, 0, 0, 100)
    g.polygon('fill', x - r - xoff, y + r - height, x + r + xoff, y + r - height, x + r, y + r, x - r, y + r)
  end

  -- Minion Animation
  local cw, ch = ctx.unitCanvas:getDimensions()
  ctx.unitCanvas:clear(0, 0, 0, 0)
  ctx.unitCanvas:renderTo(function()
    ctx.animations[minion]:draw(cw / 2, ch / 2)
  end)
  local scale = (2 * r / cw) * .9 * 3
  g.setColor(255, 255, 255)
  g.draw(ctx.unitCanvas, x, y, 0, scale, scale, cw / 2, ch / 2)

  -- Minion Rune Frames
  for j = 1, #runes do
    local x, y, w, h = unpack(runes[j])
    local scale = w / atlas:getDimensions('frame')
    g.setColor(255, 255, 255)
    g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
    if self.drag.dragSource == 'stash' and self.drag.dragAlpha > 0 then
      local alpha = math.lerp(self.drag.prevDragAlpha, self.drag.dragAlpha, ls.accum / ls.tickrate)
      g.setBlendMode('additive')
      g.setColor(255, 255, 255, 80 * alpha)
      g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
      g.setBlendMode('alpha')
    end
  end

  -- Minion Runes
  for i = 1, #runes do
    local rune = ctx.user.runes[minion][i]
    if rune and not self.drag:isDragging(minion, i) then
      local x, y, w, h = unpack(runes[i])

      local lerpd = {}
      for k, v in pairs(ctx.campaign.runeTransforms[rune]) do
        lerpd[k] = math.lerp(ctx.campaign.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
      end

      g.drawRune(rune, lerpd.x, lerpd.y, lerpd.size - .015 * v, (lerpd.size - .015 * v) * .5)
    end
  end

  -- Muju
  local color = ctx.user and ctx.user.color or 'purple'
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = ctx.animations.muju.spine.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = unpack(config.player.colors[color])
  end
  local cw, ch = ctx.unitCanvas:getDimensions()
  ctx.unitCanvas:clear(0, 0, 0, 0)
  ctx.unitCanvas:renderTo(function()
    ctx.animations.muju:draw(cw / 2, ch / 2)
  end)
  local scale = (.15 * v / cw) * 1 * 3
  g.setColor(255, 255, 255)
  local x, y = unpack(self.geometry.muju)
  g.draw(ctx.unitCanvas, x, y, 0, scale, scale, cw / 2, ch / 2)


  -- Modules
  self.play:draw()
  self.map:draw()
  self.drag:draw()
end

function MenuCampaign:keyreleased(key)
  if not self.active then return end
  if self.map:keyreleased(key) then return true end
  if key == 'escape' then
    ctx:setPage('start')
    return true
  end
end

function MenuCampaign:mousepressed(mx, my, b)
  if not self.active or self.map.focused then return end
  self.drag:mousepressed(mx, my, b)
end

function MenuCampaign:mousereleased(mx, my, b)
  if not self.active then return end
  self.map:mousereleased(mx, my, b)
  if self.map.focused then return end
  if ctx.optionsPane.active then return end
  self.drag:mousereleased(mx, my, b)
end

function MenuCampaign:gamepadpressed(gamepad, button)
  if not self.active or self.map.focused then return end
  if button == 'dpleft' then self:previousBiome()
  elseif button == 'dpright' then self:nextBiome()
  elseif button == 'start' then ctx.animations.muju:set('death')
  elseif button == 'b' then
    ctx.page = 'start'
    ctx.start.active = true
  end
end

function MenuCampaign:resize()
  self.map:resize()
  table.clear(self.geometry)
end

function MenuCampaign:setBiome(biome)
  self.biome = biome
  ctx:refreshBackground()
end

function MenuCampaign:mujuDead()
  ctx:startGame({mode = 'campaign', biome = self.biome})
end
