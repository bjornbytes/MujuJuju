HudUnits = class()

local g = love.graphics

function HudUnits:init()
  self.prevspread = {}
  self.spread = {}

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    upgrades = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local p = ctx.players:get(ctx.id)
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
      local minionInc = u * (.1 + (.18 * upgradeFactor))
      local inc = .1 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local yy = v * (.07 + (.07 * upgradeFactor)) + (.11 * v)
      local radius = math.max(.035 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        local spread1 = math.lerp(self.prevspread[i][1], self.spread[i][1], tickDelta / tickRate)
        local spread2 = math.lerp(self.prevspread[i][2], self.spread[i][2], tickDelta / tickRate)
        local spreadFactor = 3.5 - (spread1 + spread2) ^ .75

        for j = 1, 2 do
          local sign = j == 1 and -1 or 1
          local xx = xx + (inc / 2 + inc * (j == 1 and spread1 or spread2) / spreadFactor) * sign
          res[i][j] = {xx, yy, radius, {}}

          if p:hasUnitAbility(i, j) then
            for k = 1, 2 do
              local yy = yy + (.08 * v)
              local sign = k == 1 and -1 or 1
              local xx = xx + (inc / 2) * sign
              res[i][j][4][k] = {xx, yy, radius}
            end
          end
        end

        xx = xx + minionInc
      end

      return res
    end,

    runes = function()
      local u, v = ctx.hud.u, ctx.hud.v
      local upgradeFactor, t = ctx.hud.upgrades:getFactor()
      local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
      local minionInc = u * (.1 + (.18 * upgradeFactor))
      local inc = .1 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local yy = v * (.07 + (.07 * upgradeFactor)) + (.11 * v)
      local radius = math.max(.035 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        local spread1 = math.lerp(self.prevspread[i][1], self.spread[i][1], tickDelta / tickRate)
        local spread2 = math.lerp(self.prevspread[i][2], self.spread[i][2], tickDelta / tickRate)
        local yy = yy + (.08 * v) + (.02 * v) + (.1 * v) * math.max(spread1, spread2)
        res[i] = {}

        for j = 1, 3 do
          local sign = j - 2
          res[i][j] = {xx + inc * sign, yy, radius}
        end

        xx = xx + minionInc
      end

      return res
    end
  }

  self:ready()
end

function HudUnits:update()
  local p = ctx.players:get(ctx.id)

	for i = 1, #p.deck do
		self.selectFactor[i] = math.lerp(self.selectFactor[i], p.selected == i and 1 or 0, 10 * tickRate)
    for j = 1, 2 do
      self.prevspread[i][j] = self.spread[i][j]
      if p:hasUnitAbility(i, j) then
        self.spread[i][j] = math.lerp(self.spread[i][j], 1, math.min(10 * tickRate, 1))
      end
    end
	end

  local mx, my = love.mouse.getPosition()
  local runes = self.geometry.runes
  for minion = 1, #runes do
    for i = 1, #runes[minion] do
      if math.insideCircle(mx, my, unpack(runes[minion][i])) and p.deck[minion].runes[i] then
        ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:runeTooltip(p.deck[minion].runes[i].id))
      end
    end
  end

  local upgrades = self.geometry.upgrades
  for minion = 1, #upgrades do
    for upgrade = 1, #upgrades[minion] do
      local x, y, r, children = unpack(upgrades[minion][upgrade])
      if math.insideCircle(mx, my, x, y, r) then
        ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:abilityTooltip(p.deck[minion].code, upgrade))
      else
        for i = 1, #children do
          if math.insideCircle(mx, my, unpack(children[i])) then
            ctx.hud.tooltip:setTooltip(ctx.hud.tooltip:abilityUpgradeTooltip(p.deck[minion].code, upgrade, i))
          end
        end
      end
    end
  end

	for i = 1, #self.selectFactor do
		self.selectFactor[i] = math.lerp(self.selectFactor[i], p.selected == i and 1 or 0, 18 * tickRate)
		self.cooldownPop[i] = math.lerp(self.cooldownPop[i], 0, 5 * tickRate)
		if p.deck[i] then
			local y = self.bg[i]:getHeight() * (p.deck[i].cooldown / 3)
			self.selectQuad[i]:setViewport(0, y, self.bg[i]:getWidth(), self.bg[i]:getHeight() - y)
		end
	end
end

function HudUnits:draw()
  if ctx.ded then return end

  local p = ctx.players:get(ctx.id)
  if not p then return end

  local u, v = ctx.hud.u, ctx.hud.v
  local ct = self.count

  local upgradeFactor, t = ctx.hud.upgrades:getFactor()
  local upgradeAlphaFactor = (t / ctx.hud.upgrades.maxTime) ^ 3
  local inc = u * (.1 + (.18 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)
  local font = ctx.hud.boldFont

  if t < 1 then table.clear(self.geometry) end

  g.setColor(0, 0, 0, 65 * math.clamp(upgradeFactor, 0, 1))
  g.rectangle('fill', 0, 0, ctx.view.frame.width, ctx.view.frame.height)

  for i = 1, self.count do
    local bg = self.bg[i]
    local w, h = bg:getDimensions()
    local scale = (.1 + (.0175 * self.selectFactor[i]) + (.02 * upgradeFactor)) * v / w
    local yy = v * (.07 + (.07 * upgradeFactor))
    local f, cost = font, tostring('12')
    local alpha = .65 + self.selectFactor[i] * .35

    -- Backdrop
    g.setColor(255, 255, 255, 80 * alpha)
    g.draw(bg, xx, yy, 0, scale, scale, w / 2, h / 2)
    
    -- Cooldown
    local _, qy = self.selectQuad[i]:getViewport()
    local val = (150 + (100 * (p.deck[i].cooldown == 0 and 1 or 0))) * alpha
    g.setColor(255, 255, 255, val)
    g.draw(bg, self.selectQuad[i], xx, yy + qy * scale, 0, scale, scale, w / 2, h / 2)

    -- Juice
    g.setBlendMode('additive')
    g.setColor(255, 255, 255, 60 * self.cooldownPop[i])
    g.draw(bg, xx, yy, 0, scale * (1 + .2 * self.cooldownPop[i]), scale * (1 + .2 * self.cooldownPop[i]), w / 2, h / 2)
    g.setBlendMode('alpha')

    xx = xx + inc
  end

  local upgrades = self.geometry.upgrades
  for minion = 1, #upgrades do
    for upgrade = 1, 2 do
      local x, y, r, children = unpack(upgrades[minion][upgrade])
      local spread = math.lerp(self.prevspread[minion][upgrade], self.spread[minion][upgrade], tickDelta / tickRate)
      local image = data.media.graphics.menuCove
      local scale = r * 2 / 385
      local val = p:hasUnitAbility(minion, upgrade) and 255 or 150
      g.setColor(val, val, val, 255 * upgradeAlphaFactor)
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

      for i = 1, #children do
        local x, y, r = unpack(children[i])
        local image = data.media.graphics.menuCove
        local scale = r * 2 / 385
        local val = p:hasUnitAbilityUpgrade(minion, upgrade, i) and 255 or 150
        g.setColor(val, val, val, 255 * upgradeAlphaFactor * spread)
        g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      end
    end
  end

  local runes = self.geometry.runes
  for minion = 1, #runes do
    for i = 1, #runes[minion] do
      local x, y, r = unpack(runes[minion][i])
      local image = data.media.graphics.menuCove
      local scale = r * 2 / 385
      local val = p.deck[minion].runes[i] and 255 or 150
      g.setColor(val, val, val, 255 * upgradeAlphaFactor)
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  end
end

function HudUnits:mousepressed(mx, my, b)
  if ctx.ded then return end
  if b ~= 'l' then return end

  local p = ctx.players:get(ctx.id)

  local runes = self.geometry.runes
  for minion = 1, #runes do
    for i = 1, #runes[minion] do
      if math.insideCircle(mx, my, unpack(runes[minion][i])) and p.deck[minion].runes[i] then
        --
      end
    end
  end

  local upgrades = self.geometry.upgrades
  for minion = 1, #upgrades do
    for upgrade = 1, #upgrades[minion] do
      local x, y, r, children = unpack(upgrades[minion][upgrade])
      if not p:hasUnitAbility(minion, upgrade) and math.insideCircle(mx, my, x, y, r) then
        if p:spend(ctx.upgrades.costs.ability) then
          ctx.upgrades:process({unit = minion, ability = upgrade}, p)
        end
      else
        for i = 1, #children do
          if p:hasUnitAbility(minion, upgrade) and not p:hasUnitAbilityUpgrade(minion, upgrade, i) and math.insideCircle(mx, my, unpack(children[i])) then
            if p:spend(ctx.upgrades.costs.abilityUpgrade) then
              ctx.upgrades:process({unit = minion, ability = upgrade, upgrade = i}, p)
            end
          end
        end
      end
    end
  end
end

function HudUnits:ready()
  local p = ctx.players:get(ctx.id)

  self.count = #p.deck
  self.bg = {}
  self.selectFactor = {}
  self.cooldownPop = {}
  self.selectQuad = {}

  for i = 1, self.count do
    self.bg[i] = data.media.graphics.unit.portrait[p.deck[i].code] or data.media.graphics.menuCove
    self.selectFactor[i] = 0
    self.cooldownPop[i] = 0
    self.selectQuad[i] = g.newQuad(0, 0, self.bg[i]:getWidth(), self.bg[i]:getHeight(), self.bg[i]:getWidth(), self.bg[i]:getHeight())

    self.prevspread[i] = {0, 0}
    self.spread[i] = {0, 0}
  end
end
