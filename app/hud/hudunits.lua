HudUnits = class()

local g = love.graphics

function HudUnits:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    units = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local atlas = data.atlas.hud
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local inc = u * (.2 + (.075 * upgradeFactor))
      local xx = .5 * u - (inc * (self.count - 1) / 2)
      local p = ctx.player
      local w, h = data.atlas.hud:getDimensions('minion')
      local res = {scale = scale, imageScale = is}

      for i = 1, self.count do
        local deck = p.deck[i]
        local yy = v * .005
        res[i] = {x = xx, y = yy}

        local selectFactor = math.lerp(self.prevSelectFactor[i], self.selectFactor[i], ls.accum / ls.tickrate)
        local scale = 1 + .6 * upgradeFactor + .1 * selectFactor
        local is = (.2 * scale * v) / h
        res[i].selectFactor = selectFactor
        res[i].scale = scale
        res[i].imageScale = is

        -- Background
        res[i].bg = {xx, yy, 0, is, is, w / 2, 0}

        -- Title bar
        local w, h = atlas:getDimensions('title')
        local tx = xx - (w / 2) * is
        local ty = yy + (10 * is)
        local xsc = is * (1 - (deck.cooldown / deck.maxCooldown))
        res[i].title = {xx, ty, 0, is, is, w / 2, 0}

        -- Runes
        do
          local runes = {}
          local ct = p.deck[i].runes and #p.deck[i].runes or 0
          local size = v * .0385 * is
          local inc = size * 3
          local xx = xx - (inc * (ct - 1) / 2)
          local yy = yy + .174 * v * scale
          for j = 1, ct do
            local rune = p.deck[i].runes and p.deck[i].runes[j]
            runes[j] = {}

            -- Stone
            local w, h = atlas:getDimensions('runeBg' .. rune.background:capitalize())
            local scale = size * 2 / h
            runes[j].bg = {'runeBg' .. rune.background:capitalize(), xx, yy, 0, scale, scale, w / 2, h / 2}

            -- Rune
            local w, h = atlas:getDimensions('rune' .. rune.image)
            local scale = (size - .01 * v * is) / h
            runes[j].rune = {'rune' .. rune.image, xx, yy, 0, scale, scale, w / 2, h / 2}

            xx = xx + inc
          end

          res[i].runes = runes
        end

        xx = xx + inc
      end

      return res
    end,

    upgrades = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local p = ctx.player
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local inc = .1 * upgradeFactor * v
      local yy = (.15 * upgradeFactor) * v + (.35 * v)
      local size = math.max(.08 * v * upgradeFactor, .01)
      local units = self.geometry.units
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        local xx = units[i].x

        for j, upgrade in ipairs(data.unit[p.deck[i].code].upgrades) do
          local line = {}
          if upgrade.connectedTo then
            table.each(upgrade.connectedTo, function(other, k)
              local connection = data.unit[p.deck[i].code].upgrades[other]
              line[k] = {xx + (inc * upgrade.x), yy + (.1 * v * upgrade.y), xx + (inc * connection.x), yy + (.1 * v * connection.y)}
            end)
          end
          table.insert(res[i], {xx + (inc * upgrade.x) - size / 2, yy + (.1 * v * upgrade.y) - size / 2, size, size, line})
        end
      end

      return res
    end,

    attributes = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local inc = .1 * upgradeFactor * v
      local yy = (.15 * upgradeFactor) * v + (.25 * v)
      local size = math.max(.08 * v * upgradeFactor, .01)
      local units = self.geometry.units
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        local x = units[i].x - (inc * (4 - 1) / 2)
        for j = 1, 4 do
          table.insert(res[i], {x - size / 2, yy - size / 2, size, size})
          x = x + inc
        end
      end

      return res
    end
  }

  self:ready()
end

function HudUnits:update()
  local p = ctx.player

	for i = 1, #self.selectFactor do
    self.prevSelectFactor[i] = self.selectFactor[i]
		self.selectFactor[i] = math.lerp(self.selectFactor[i], p.deck[i].selected and 1 or (p.summonSelect == i and .5 or 0), math.min(8 * ls.tickrate, 1))
    if self.selectFactor[i] > .01 and self.selectFactor[i] < .99 then table.clear(self.geometry) end
	end

	for i = 1, #self.cooldownPop do
    self.prevCooldownPop[i] = self.cooldownPop[i]
		self.cooldownPop[i] = math.lerp(self.cooldownPop[i], 0, math.min(12 * ls.tickrate, 1))
	end

  local _, t = ctx.hud.upgrades:getFactor()
  if t ~= 0 and t ~= 1 then ctx:mousemoved(love.mouse.getPosition()) end
end

function HudUnits:draw()
  if ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local upgradeFactor, t = ctx.hud.upgrades:getFactor()

  if t > 0 and t < 1 then table.clear(self.geometry) end

  self:drawBackground()
  self:drawForeground()
end

function HudUnits:drawBackground()
  local u, v = ctx.hud.u, ctx.hud.v
  local ct = self.count
  local p = ctx.player

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3

  local units = self.geometry.units

  self.spriteBatch:bind()

  if upgradeFactor > 0 then
    g.setColor(0, 0, 0, 80 * math.clamp(upgradeFactor, 0, 1))
    g.rectangle('fill', 0, 0, u, v)
  end

  for i = 1, #units do
    local unit = units[i]
    local xx, yy = unit.x, unit.y
    local deck = p.deck[i]
    local selectFactor = math.lerp(self.prevSelectFactor[i], self.selectFactor[i], ls.accum / ls.tickrate)
    local alpha = .45 + selectFactor * .35

    -- Backdrop
    g.setColor(255, 255, 255, 255 * alpha)
    self:batch('bg' .. i, 'minion', unpack(unit.bg))

    -- Cooldown
    g.setColor(255, 255, 255, 80 * alpha)
    local x, y, a, sx, sy, ox, oy = unpack(unit.title)
    self:batch('title' .. i, 'title', x, y, a, sx, sy, ox, oy)

    g.setColor(255, 255, 255, 255 * alpha)
    local cd = 1 - (deck.cooldown / deck.maxCooldown)
    self:batch('titleBar' .. i, 'title', x - ox * sx, y, a, sx * cd, sy)

    -- Runes
    for j = 1, #unit.runes do
      g.setColor(255, 255, 255)
      self:batch('runeBg' .. i .. j, unpack(unit.runes[j].bg))
      g.setColor(config.runes.colors[deck.runes[j].color])
      self:batch('rune' .. i .. j, unpack(unit.runes[j].rune))
    end
  end

  if t > 0 then

    -- Attributes
    local attributes = self.geometry.attributes
    for i = 1, #attributes do
      for j = 1, #attributes[i] do
        local x, y, w, h = unpack(attributes[i][j])
        local attribute = config.attributes.list[j]
        local scale = w / data.atlas.hud:getDimensions('frame')
        g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
        self:batch('attributeFrame' .. i .. j, 'frame', x, y, 0, scale, scale)

        local image = data.media.graphics.hud.icons[attribute]
        if image then
          local scale = math.min((w - (v * .03)) / image:getWidth(), (h - (v * .03)) / image:getHeight())
          local code = 'attributeIcon' .. i .. j
          self:batch(code, attribute, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
        end
      end
    end

    -- Upgrade Connectors
    local upgrades = self.geometry.upgrades
    g.setLineWidth(2)
    for i = 1, #upgrades do
      for j = 1, #upgrades[i] do
        local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
        local _, _, _, _, line = unpack(upgrades[i][j])
        local upgrade = data.unit[who].upgrades[what]

        if line and #line > 0 then
          table.each(line, function(points, k)
            local other = data.unit[p.deck[i].code].upgrades[upgrade.connectedTo[k]]
            if other.level >= upgrade.prerequisites[other.code] then
              g.setColor(0, ctx.options.colorblind and 0 or 200, ctx.options.colorblind and 200 or 0, 200 * upgradeAlphaFactor ^ 2)
            else
              g.setColor(200, 0, 0, 200 * upgradeAlphaFactor ^ 2)
            end
            local xscale = .005 * v
            local yscale = math.distance(unpack(points)) / 20
            local angle = math.direction(unpack(points)) - math.pi / 2
            self:batch('upgradeConector' .. i .. j .. k, 'healthbarBar', points[1], points[2], angle, xscale, yscale, .5, 0)
          end)
        end
      end
    end
    g.setLineWidth(1)

    -- Upgrades
    local upgrades = self.geometry.upgrades
    for i = 1, #upgrades do
      for j = 1, #upgrades[i] do
        local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
        local x, y, w, h = unpack(upgrades[i][j])
        local scale = w / data.atlas.hud:getDimensions('frame')
        local upgrade = data.unit[who].upgrades[what]
        local val = (upgrade.level > 0 or ctx.upgrades.canBuy(who, what)) and 255 or 150
        x, y = math.round(x), math.round(y)

        -- Frame
        g.setColor(val, val, val, 255 * upgradeAlphaFactor)
        self:batch('upgradeFrame' .. i .. j, 'frame', x, y, 0, scale, scale)

        -- Icon
        local image = data.media.graphics.hud.icons[what]
        if image then
          local val = (upgrade.level > 0 or ctx.upgrades.canBuy(who, what)) and 255 or 200
          local scale = math.min((w - (v * .02)) / image:getWidth(), (h - (v * .02)) / image:getHeight())
          local x, y = x + w / 2, y + h / 2
          local ox, oy = image:getWidth() / 2, image:getHeight() / 2
          local code = 'upgradeIcon' .. i .. j
          g.setColor(val, val, val, 255 * upgradeAlphaFactor)
          self:batch(code, what, x, y, 0, scale, scale, ox, oy)
        end
      end
    end
  end

  self.spriteBatch:unbind()
  g.draw(self.spriteBatch)
end

function HudUnits:drawForeground()
  local u, v = ctx.hud.u, ctx.hud.v
  local mx, my = love.mouse.getPosition()
  local p = ctx.player
  local atlas = data.atlas.hud

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
  local units = self.geometry.units

  for i = 1, #units do
    local unit = units[i]
    local xx, yy = unit.x, unit.y
    local deck = p.deck[i]
    local alpha = .45 + unit.selectFactor * .35
    local scale = unit.scale
    local imageScale = unit.imageScale

    -- Cooldown
    local cooldownPop = math.lerp(self.prevCooldownPop[i], self.cooldownPop[i], ls.accum / ls.tickrate)
    g.setBlendMode('additive')
    g.setColor(255, 255, 255, 200 * cooldownPop)
    g.draw(atlas.texture, atlas.quads.title, unpack(unit.title))
    g.setBlendMode('alpha')

    -- Animation
    g.setCanvas(self.canvas)
    self.canvas:clear(0, 0, 0, 0)
    g.pop()
    self.animations[i]:draw(100, 100)
    ctx.view:guiPush()
    g.setCanvas()
    g.setColor(255, 255, 255)
    g.draw(self.canvas, xx, yy + .1 * scale * v, 0, imageScale, imageScale, 100, 100)

    -- Text
    local x, y, a, sx, sy, ox, oy = unpack(unit.title)
    local w, h = data.atlas.hud:getDimensions('title')
    local unit = data.unit[p.deck[i].code]
    local font = g.setFont('mesmerize', math.round(.02 * scale * v))
    local str = unit.name
    if math.inside(mx, my, x - ox * sx, y, w * sx, h * sy) then
      str = string.format('%.2f', p.deck[i].cooldown)
    end
    g.setColor(255, 255, 255)
    g.printShadow(str, math.round(xx), math.round(yy + (.025 * v * scale)), true)
    g.printShadow(unit.cost, xx - (.09125 * v * scale), yy + (.0975 * v * scale), true, {0, 100, 0, 200})

    local count = table.count(ctx.units:filter(function(u) return u.class.code == p.deck[i].code end))
    g.printShadow(count, xx + (.087 * v * scale), yy + (.1 * v * scale), true, {0, 100, 0, 200})
  end

  if t > 0 then

    -- Attribute text
    local attributes = self.geometry.attributes
    for i = 1, #attributes do
      for j = 1, #attributes[i] do
        local x, y, w, h = unpack(attributes[i][j])
        local attribute = config.attributes.list[j]
        local level = data.unit[p.deck[i].code].attributes[attribute]
        g.setFont('mesmerize', math.round(.0175 * v))
        g.setColor(200, 200, 200, 255 * upgradeAlphaFactor)
        g.printShadow(level, x + .01 * v, y + .01 * v)
      end
    end

    -- Upgrade outlines
    local upgrades = self.geometry.upgrades
    for i = 1, #upgrades do
      for j = 1, #upgrades[i] do
        local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
        local upgrade = data.unit[who].upgrades[what]

        if upgrade.level > 0 then
          local x, y, w, h = unpack(upgrades[i][j])
          x, y = math.round(x), math.round(y)
          g.setColor(upgrade.level < upgrade.maxLevel and (ctx.options.colorblind and {0, 0, 255, 100} or {0, 255, 0, 100}) or {0, 150, 0, 100})
          g.rectangle('line', x + .5, y + .5, w - 1, h - 1)
        end
      end
    end
  end
end

function HudUnits:mousereleased(mx, my, b)
  if ctx.ded then return end
  if b ~= 'l' then return end

  mx, my = ctx.view:frameMouseX(), ctx.view:frameMouseY()

  local p = ctx.player

  -- Upgrade click
  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
      local x, y, w, h = unpack(upgrades[i][j])
      if math.inside(mx, my, x, y, w, h) then
        local upgrade = data.unit[who].upgrades[what]
        local nextLevel = upgrade.level + 1
        if ctx.upgrades.canBuy(who, what) and p:spend(upgrade.costs[nextLevel]) then
          ctx.upgrades.unlock(who, what)
        else
          ctx.sound:play('misclick')
        end
      end
    end
  end

  -- Attribute click
  local attributes = self.geometry.attributes
  for i = 1, #attributes do
    for j = 1, #attributes[i] do
      local attribute = config.attributes.list[j]
      local x, y, w, h = unpack(attributes[i][j])
      if math.inside(mx, my, x, y, w, h) then
        local class = data.unit[p.deck[i].code]
        if p:spend(50) then
          class.attributes[attribute] = class.attributes[attribute] + 1
        else
          ctx.sound:play('misclick')
        end
      end
    end
  end
end

function HudUnits:mousemoved(mx, my)
  local p = ctx.player

  mx, my = ctx.view:frameMouseX(), ctx.view:frameMouseY()

  -- Attribute tooltips
  local attributes = self.geometry.attributes
  for i = 1, #attributes do
    for j = 1, #attributes[i] do
      local attribute = config.attributes.list[j]
      local x, y, w, h = unpack(attributes[i][j])
      if math.inside(mx, my, x, y, w, h) then
        ctx.hud.tooltip:setAttributeTooltip(attribute, p.deck[i].code)
        return
      end
    end
  end

  -- Upgrade tooltips
  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
      local x, y, w, h = unpack(upgrades[i][j])
      if math.inside(mx, my, x, y, w, h) then
        ctx.hud.tooltip:setUpgradeTooltip(who, what)
        return
      end
    end
  end

  -- Rune tooltips
  local units = self.geometry.units
  for i = 1, #units do
    local unit = units[i]
    for j = 1, #unit.runes do
      local rune = unit.runes[j]
      local w, h = data.atlas.hud:getDimensions('runeBgNormal')
      local x, y, w, h = rune.bg[2], rune.bg[3], rune.bg[5] * w, rune.bg[6] * h
      if math.inside(mx, my, x - w / 2, y - h / 2, w, h) then
        ctx.hud.tooltip:setRuneTooltip(p.deck[i].runes[j])
        return
      end
    end
  end
end

function HudUnits:ready()
  local p = ctx.player

  self.count = #p.deck
  self.selectFactor = {}
  self.prevSelectFactor = {}
  self.cooldownPop = {}
  self.prevCooldownPop = {}
  self.animations = {}
  self.canvas = g.newCanvas(200, 200)
  self.spriteBatch = g.newSpriteBatch(data.atlas.hud.texture, 512, 'stream')
  self.spriteBatchMap = {}

  local animationScaleFactors = {
    bruju = 1.5,
    thuju = .85,
    buju = .85,
    kuju = .85
  }

  local animationOffsets = {
    bruju = -12,
    thuju = -16,
    buju = -16,
    kuju = -16
  }

  for i = 1, self.count do
    self.selectFactor[i] = 0
    self.prevSelectFactor[i] = self.selectFactor[i]
    self.cooldownPop[i] = 0
    self.prevCooldownPop[i] = self.cooldownPop[i]
    local code = p.deck[i].code
    local animation = data.animation[code]
    local scale = animation.scale * animationScaleFactors[code]
    local offsety = animation.offsety + animationOffsets[code]
    self.animations[i] = data.animation[p.deck[i].code]({scale = scale, offsety = offsety})
    self.animations[i]:on('complete', function()
      self.animations[i]:set('idle', {force = true})
    end)
  end
end

function HudUnits:batch(code, quad, ...)
  local id = self.spriteBatchMap[code]
  self.spriteBatch:setColor(love.graphics.getColor())

  if id then
    self.spriteBatch:set(id, data.atlas.hud.quads[quad], ...)
  else
    self.spriteBatchMap[code] = self.spriteBatch:add(data.atlas.hud.quads[quad], ...)
  end
end
