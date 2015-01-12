HudUnits = class()

local g = love.graphics

function HudUnits:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    upgrades = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local p = ctx.player
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local minionInc = (.2 * u) + (.075 * upgradeFactor * u)
      local inc = .1 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local yy = (.15 * upgradeFactor) * v + (.35 * v)
      local size = math.max(.08 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        res[i] = {}

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

        xx = xx + minionInc
      end

      return res
    end,

    attributes = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local p = ctx.player
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local minionInc = (.2 * u) + (.075 * upgradeFactor * u)
      local inc = .1 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local yy = (.15 * upgradeFactor) * v + (.25 * v)
      local size = math.max(.08 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        local x = xx - (inc * (4 - 1) / 2)
        for j = 1, 4 do
          table.insert(res[i], {x - size / 2, yy - size / 2, size, size})
          x = x + inc
        end

        xx = xx + minionInc
      end

      return res
    end
  }

  self:ready()
end

function HudUnits:update()
  local p = ctx.player
  local mx, my = love.mouse.getPosition()

  local attributes = self.geometry.attributes
  for i = 1, #attributes do
    for j = 1, #attributes[i] do
      local attribute = config.attributes[j]
      local x, y, w, h = unpack(attributes[i][j])
      if math.inside(mx, my, x, y, w, h) then
        ctx.hud.tooltip:setAttributeTooltip(attribute, p.deck[i].code)
      end
    end
  end

  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
      local x, y, w, h = unpack(upgrades[i][j])
      if math.inside(mx, my, x, y, w, h) then
        ctx.hud.tooltip:setUpgradeTooltip(who, what)
      end
    end
  end

	for i = 1, #self.selectFactor do
    self.prevSelectFactor[i] = self.selectFactor[i]
		self.selectFactor[i] = math.lerp(self.selectFactor[i], p.deck[i].selected and 1 or (p.summonSelect == i and .5 or 0), 8 * tickRate)
	end

	for i = 1, #self.cooldownPop do
    self.prevCooldownPop[i] = self.cooldownPop[i]
		self.cooldownPop[i] = math.lerp(self.cooldownPop[i], 0, 12 * tickRate)
	end

  -- TODO clean up rune tooltips
  local u, v = ctx.hud.u, ctx.hud.v
  local ct = self.count
  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local inc = u * (.2 + (.075 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)
  for i = 1, ct do
    local selectFactor = math.lerp(self.prevSelectFactor[i], self.selectFactor[i], tickDelta / tickRate)
    local bg = data.media.graphics.hud.minion
    local w, h = bg:getDimensions()
    local scale = (.25 + (.12 * upgradeFactor) + (.02 * selectFactor)) * v / w
    local yy = v * (.01 * selectFactor)
    local runeCount = p.deck[i].runes and #p.deck[i].runes or 0
    local runeSize = v * .032 * scale
    local runeInc = runeSize * 3
    local runex = xx - (runeInc * (runeCount - 1) / 2)
    local runey = yy + .365 * v * scale
    for j = 1, runeCount do
      if math.insideCircle(mx, my, runex, runey, runeSize) then
        ctx.hud.tooltip:setRuneTooltip(p.deck[i].runes[j])
      end
      runex = runex + runeInc
    end
    xx = xx + inc
  end
end

function HudUnits:draw()
  if ctx.ded then return end

  local p = ctx.player
  if not p then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local mx, my = love.mouse.getPosition()
  local ct = self.count

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
  local inc = u * (.2 + (.075 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)

  if t < 1 then table.clear(self.geometry) end

  g.setColor(0, 0, 0, 80 * math.clamp(upgradeFactor, 0, 1))
  g.rectangle('fill', 0, 0, ctx.view.frame.width, ctx.view.frame.height)

  for i = 1, self.count do
    local selectFactor = math.lerp(self.prevSelectFactor[i], self.selectFactor[i], tickDelta / tickRate)
    local bg = data.media.graphics.hud.minion
    local w, h = bg:getDimensions()
    local scale = (.25 + (.12 * upgradeFactor) + (.02 * selectFactor)) * v / w
    local yy = v * (.01 * selectFactor)
    local alpha = .45 + selectFactor * .35

    -- Backdrop
    g.setColor(255, 255, 255, 255 * alpha)
    g.draw(bg, xx, yy, 0, scale, scale, w / 2, 0)

    -- Cooldown
    local title = data.media.graphics.hud.title
    local titlex = xx - (title:getWidth() / 2) * scale
    g.setColor(255, 255, 255, 80 * alpha)
    g.draw(title, xx, yy + (10 * scale), 0, scale, scale, title:getWidth() / 2, 0)
    g.setColor(255, 255, 255, 255 * alpha)
    g.draw(title, titlex, yy + (10 * scale), 0, scale * (1 - (p.deck[i].cooldown / p.deck[i].maxCooldown)), scale)

    local cooldownPop = math.lerp(self.prevCooldownPop[i], self.cooldownPop[i], tickDelta / tickRate)
    g.setBlendMode('additive')
    g.setColor(255, 255, 255, 200 * cooldownPop)
    g.draw(title, xx, yy + (10 * scale), 0, scale, scale, title:getWidth() / 2, 0)
    g.setBlendMode('alpha')

    -- Animation
    self.canvas[i]:clear(0, 0, 0, 0)
    g.setCanvas(self.canvas[i])
    self.animations[i]:draw(100, 100)
    g.setCanvas()
    g.draw(self.canvas[i], xx, yy + .2 * scale * v, 0, scale, scale, 100, 100)

    -- Text
    local unit = data.unit[p.deck[i].code]
    local font = g.setFont('mesmerize', math.round(.04 * scale * v))
    local str = unit.name
    if math.inside(mx, my, titlex, yy + (10 * scale), title:getWidth() * scale, title:getHeight() * scale) then
      str = string.format('%.2f', p.deck[i].cooldown)
    end
    g.setColor(255, 255, 255)
    g.printCenter(str, math.round(xx), math.round(yy + (.05 * v * scale)))

    g.setColor(0, 100, 0, 200)
    g.printCenter(unit.cost, xx - (.19 * v * scale) + 1, yy + (.204 * v * scale) + 2)
    g.setColor(255, 255, 255)
    g.printCenter(unit.cost, xx - (.19 * v * scale), yy + (.204 * v * scale))

    local count = table.count(ctx.units:filter(function(u) return u.class.code == p.deck[i].code end))
    g.setColor(0, 100, 0, 200)
    g.printCenter(count, xx + (.1825 * v * scale) + 1, yy + (.21 * v * scale) + 2)
    g.setColor(255, 255, 255)
    g.printCenter(count, xx + (.1825 * v * scale), yy + (.21 * v * scale))

    -- Runes
    local runeCount = p.deck[i].runes and #p.deck[i].runes or 0
    local runeSize = v * .04 * scale
    local runeInc = runeSize * 3
    local runex = xx - (runeInc * (runeCount - 1) / 2)
    local runey = yy + .365 * v * scale
    g.setColor(255, 255, 255, 255 * alpha)
    for j = 1, runeCount do
      local rune = p.deck[i].runes and p.deck[i].runes[j]
      g.drawRune(rune, runex, runey, runeSize * 2, (runeSize - .01175 * v) * 2)
      runex = runex + runeInc
    end
    
    xx = xx + inc
  end

  -- Attributes
  local attributes = self.geometry.attributes
  for i = 1, #attributes do
    for j = 1, #attributes[i] do
      local x, y, w, h = unpack(attributes[i][j])
      local image = data.media.graphics.hud.frame
      local scale = w / image:getWidth()
      g.setColor(255, 255, 255, 255 * upgradeAlphaFactor)
      g.draw(image, x, y, 0, scale, scale)

      local attribute = data.unit[p.deck[i].code].attributes[config.attributes[j]]
      g.setFont('pixel', 8)
      g.setColor(200, 200, 200, 255 * upgradeAlphaFactor)
      g.printShadow(attribute.level, x + 6, y + 2)
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
            g.setColor(0, 200, 0, 200 * upgradeAlphaFactor)
          else
            g.setColor(200, 0, 0, 200 * upgradeAlphaFactor)
          end
          g.line(points)
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
      local image = data.media.graphics.hud.frame
      local scale = w / image:getWidth()
      local upgrade = data.unit[who].upgrades[what]
      local val = upgrade.level > 0 and 255 or 150
      g.setColor(val, val, val, 255 * upgradeAlphaFactor)
      g.draw(image, x, y, 0, scale, scale)

      local image = data.media.graphics.hud.icons[what]
      if image then
        local scale = math.min((w - (v * .02)) / image:getWidth(), (h - (v * .02)) / image:getHeight())
        g.draw(image, x + w / 2, y + h / 2, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      end

      local str = upgrade.level .. '/' .. upgrade.maxLevel
      g.setFont('pixel', 8)
      g.setColor(200, 200, 200, 255 * upgradeAlphaFactor)
      g.printShadow(str, x + 6, y + 2)
      local cost = upgrade.costs[upgrade.level + 1]
      if cost then
        local y = y + 2 + g.getFont():getHeight()
        if p.juju >= cost then g.setColor(100, 255, 100, 200 * upgradeAlphaFactor)
        else g.setColor(255, 100, 100, 200 * upgradeAlphaFactor) end
        g.printShadow(cost, x + 6, y)
      end
    end
  end
end

function HudUnits:mousereleased(mx, my, b)
  if ctx.ded then return end
  if b ~= 'l' then return end

  local p = ctx.player

  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgrades[j].code
      local x, y, w, h = unpack(upgrades[i][j])
      if math.inside(mx, my, x, y, w, h) then
        local upgrade = data.unit[who].upgrades[what]
        local nextLevel = upgrade.level + 1
        local cost = upgrade.costs[nextLevel]
        if ctx.upgrades.canBuy(who, what) and p.skillPoints > 0 then
          p.skillPoints = p.skillPoints - 1
          ctx.upgrades.unlock(who, what)
        else
          ctx.sound:play('misclick')
        end
      end
    end
  end

  local attributes = self.geometry.attributes
  for i = 1, #attributes do
    for j = 1, #attributes[i] do
      local attribute = config.attributes[j]
      local x, y, w, h = unpack(attributes[i][j])
      if math.inside(mx, my, x, y, w, h) then
        local attribute = data.unit[p.deck[i].code].attributes[config.attributes[j]]
        local cost = ctx.upgrades.attributeCostBase + (ctx.upgrades.attributeCostIncrease * attribute.level)
        if p:spend(cost) then
          attribute.level = attribute.level + 1
          table.each(ctx.units.objects, function(unit)
            if unit.class.code == p.deck[i].code then
              unit[attribute.stat] = unit[attribute.stat] + attribute.amount
              if attribute.stat == 'health' then
                unit.maxHealth = unit.maxHealth + attribute.amount
              end
            end
          end)
        else
          ctx.sound:play('misclick')
        end
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
  self.canvas = {}

  local animationScaleFactors = {
    bruju = 1.5,
    thuju = .85,
    buju = .85
  }

  local animationOffsets = {
    bruju = 0,
    thuju = -14,
    buju = 0
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
    self.canvas[i] = love.graphics.newCanvas(200, 200)
    self.animations[i]:on('complete', function()
      self.animations[i]:set('idle', {force = true})
    end)
  end
end
