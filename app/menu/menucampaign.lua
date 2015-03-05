local g = love.graphics
MenuCampaign = class()

local minionMap = {
  forest = 'bruju',
  cavern = 'xuju',
  tundra = 'kuju',
  volcano = 'thuju'
}

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
      local u, v = love.graphics.getDimensions()
      local size = .2 * v
      local runeSize = .08 * v
      local runeInc = runeSize + .02 * v
      local x = .15 * u
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
      local size = .08 * v
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
      local h = v * .34
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
      local frame = self.geometry.runesFrame
      local w, h = .2 * u, .13 * v
      local midx = (u + frame[1] + frame[3]) / 2
      return {midx - w / 2, .14 * v, w, h}
    end,

    muju = function()
      local u, v = ctx.u, ctx.v
      return {u * .75, v * .8}
    end
  }

  self:setBiome('forest')

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

  self.map.focused = true
  self.map.factor = 1
end

function MenuCampaign:deactivate()
  self.map.active = false
  self.drag.active = false
end

function MenuCampaign:update()
  if not self.active then return end

  self.map:update()

  local mx, my = love.mouse.getPosition()
  local u, v = ctx.u, ctx.v

  local runes = self.geometry.minion[4]
  for i = 1, #runes do
    local rune = ctx.user.runes[self.minion][i]
    if rune and not self.drag:isDragging('equippedRune', i) then
      local x, y, w, h = unpack(runes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)

      if math.inside(mx, my, x, y, w, h) then
        ctx.tooltip:setRuneTooltip(rune)
      end
    end
  end

  local runes = self.geometry.runes
  for i = 1, #runes do
    local rune = ctx.user.runes.stash[i]
    if rune and not self.drag:isDragging('rune', i) then
      local x, y, w, h = unpack(runes[i])

      lerpRune(rune, 'x', x + w / 2)
      lerpRune(rune, 'y', y + h / 2)

      if math.inside(mx, my, x, y, w, h) then
        ctx.tooltip:setRuneTooltip(rune)
      end
    end
  end

  self.drag:update()
end

function MenuCampaign:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  local ps = love.window.getPixelScale()

  local atlas = data.atlas.hud

  local detailsAlpha = 255
  local biome = self.biome
  local midx = self.geometry.play[1] + self.geometry.play[3] / 2
  local medalSize = v * .03
  local medalInc = (medalSize * 3 + (v * .02))
  local medalX = midx - medalInc * (3 - 1) / 2
  local medalY = .3 * v + medalSize + (v * .05)
  for i, benchmark in ipairs({'bronze', 'silver', 'gold'}) do
    local achieved = ctx.user.campaign.medals[biome][benchmark]
    g.setColor(255, 255, 255, (achieved and 1 or .4) * detailsAlpha)
    local image = data.media.graphics.menu[benchmark]
    local scale = medalSize * 2 / image:getWidth() * (achieved and 1 or .8)
    g.draw(image, medalX, medalY, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    g.drawRune(ctx.user.runes[i], medalX, medalY + .15 * v, .1 * v - .02 * v, .1 * v - .06 * v)
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
    local rune = ctx.user.runes.stash[i]
    if rune and not self.drag:isDragging('gutterRune', i) then
      local lerpd = {}
      for k, v in pairs(ctx.campaign.runeTransforms[rune]) do
        lerpd[k] = math.lerp(ctx.campaign.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
      end
      g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .05 * v)
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
  local unit = data.unit[self.minion]
  g.setColor(255, 255, 255)
  g.setFont('mesmerize', .08 * v)
  g.printShadow(unit.name, .26 * u, .16 * v)
  g.setFont('mesmerize', .02 * v)
  g.setColor(0, 0, 0)
  g.printf(unit.description, .26 * u + 1, .26 * v + 1, .35 * u)
  g.setColor(255, 255, 255)
  g.printf(unit.description, .26 * u, .26 * v, .35 * u)

  -- Minion
  local x, y, r, runes = unpack(self.geometry.minion)
  local code = self.minion
  g.setColor(255, 255, 255)

  -- Stage
  g.setColor(0, 0, 0, 100)
  local xoff = .02 * v
  local height = .04 * v
  g.polygon('fill', x - r - xoff, y + r - height, x + r + xoff, y + r - height, x + r, y + r, x - r, y + r)

  -- Animation
  ctx.animations[code].scale = ctx.animationScales[code]
  ctx.animations[code]:draw(x, y)

  -- Minion Rune Frames
  for j = 1, #runes do
    local x, y, w, h = unpack(runes[j])
    local scale = w / atlas:getDimensions('frame')
    g.setColor(255, 255, 255)
    g.draw(atlas.texture, atlas.quads.frame, x, y, 0, scale, scale)
  end

  -- Minion Runes
  for i = 1, #runes do
    local rune = ctx.user.runes[self.minion][i]
    if rune and not self.drag:isDragging('equippedRune', i) then
      local x, y, w, h = unpack(runes[i])

      local lerpd = {}
      for k, v in pairs(ctx.campaign.runeTransforms[rune]) do
        lerpd[k] = math.lerp(ctx.campaign.prevRuneTransforms[rune][k] or v, v, ls.accum / ls.tickrate)
      end

      g.drawRune(rune, lerpd.x, lerpd.y, h - .02 * v, h - .05 * v)
    end
  end

  -- Muju
  g.setColor(255, 255, 255)
  g.push()
  g.translate(unpack(self.geometry.muju))
  g.scale(MenuOptions.pixelScale)
  ctx.animations.muju:draw(0, 0)
  g.pop()

  local color = ctx.user and ctx.user.color or 'purple'
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = ctx.animations.muju.spine.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = unpack(config.player.colors[color])
  end

  -- Modules
  self.play:draw()
  self.map:draw()
  self.drag:draw()
end

function MenuCampaign:keypressed(key)
  return self.map:keypressed(key)
end

function MenuCampaign:mousepressed(mx, my, b)
  self.map:mousepressed(mx, my, b)

  if not self.active or self.map.focused then return end

  self.drag:mousepressed(mx, my, b)
end

function MenuCampaign:mousereleased(mx, my, b)
  if not self.active or self.map.focused then return end
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
  self.minion = minionMap[biome]
  ctx:refreshBackground()
end
