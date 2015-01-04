local rich = require 'lib/deps/richtext/richtext'

HudUnits = class()

local g = love.graphics

function HudUnits:init()
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
      local yy = v * (.07 + (.1 * upgradeFactor)) + (.11 * v)
      local radius = math.max(.035 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        local x = xx - (inc * (3 - 1) / 2)
        for j = 1, 3 do
          table.insert(res[i], {x, yy, radius})
          x = x + inc
        end

        local x = xx - (inc * (2 - 1) / 2)
        yy = yy + .08 * v
        for j = 1, 2 do
          table.insert(res[i], {x, yy, radius})
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
  local p = ctx.players:get(ctx.id)

  ctx.hud.tooltip = nil
  local mx, my = love.mouse.getPosition()
  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgradeOrder[j]
      local x, y, r = unpack(upgrades[i][j])
      if math.insideCircle(mx, my, x, y, r) then
        local str = ctx.upgrades.makeTooltip(who, what)
        ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
				ctx.hud.tooltipRaw = str:gsub('{%a+}', '')
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
  for i = 1, #upgrades do
    for j = 1, 5 do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgradeOrder[j]
      local x, y, r = unpack(upgrades[i][j])
      local image = data.media.graphics.menuCove
      local scale = r * 2 / 385
      local upgrade = data.unit[who].upgrades[what]
      local val = upgrade.level > 0 and 255 or 150
      g.setColor(val, val, val, 255 * upgradeAlphaFactor)
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    end
  end
end

function HudUnits:mousereleased(mx, my, b)
  if ctx.ded then return end
  if b ~= 'l' then return end

  local p = ctx.players:get(ctx.id)

  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgradeOrder[j]
      local x, y, r = unpack(upgrades[i][j])
      if math.distance(mx, my, x, y) <= r then
        local upgrade = data.unit[who].upgrades[what]
        local nextLevel = upgrade.level + 1
        local cost = upgrade.costs[nextLevel]
        if ctx.upgrades.canBuy(who, what) and p:spend(cost) then
          upgrade.level = nextLevel
          ctx.sound:play({sound = 'menuClick'})
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
  end
end
