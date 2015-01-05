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
      local minionInc = (.2 * u) + (.075 * upgradeFactor * u)
      local inc = .15 * upgradeFactor * v
      local xx = .5 * u - (minionInc * (self.count - 1) / 2)
      local radius = math.max(.05 * v * upgradeFactor, .01)
      local res = {}

      for i = 1, self.count do
        res[i] = {}

        local yy = (.2 * upgradeFactor) * v + (.25 * v)
        local x = xx - (inc * (3 - 1) / 2)
        for j = 1, 3 do
          table.insert(res[i], {x, yy, radius})
          x = x + inc
        end

        local x = xx - (inc * (2 - 1) / 2)
        yy = yy + .12 * v
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
  local mx, my = love.mouse.getPosition()

  local upgrades = self.geometry.upgrades
  for i = 1, #upgrades do
    for j = 1, #upgrades[i] do
      local who, what = p.deck[i].code, data.unit[p.deck[i].code].upgradeOrder[j]
      local x, y, r = unpack(upgrades[i][j])
      if math.insideCircle(mx, my, x, y, r) then
        if not ctx.hud.tooltip then
          local str = ctx.upgrades.makeTooltip(who, what)
          ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
          ctx.hud.tooltipRaw = str:gsub('{%a+}', '')
        end
        ctx.hud.tooltipHover = true
      end
    end
  end

	for i = 1, #self.selectFactor do
		self.selectFactor[i] = math.lerp(self.selectFactor[i], p.selected == i and 1 or 0, 18 * tickRate)
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
  local inc = u * (.2 + (.075 * upgradeFactor))
  local xx = .5 * u - (inc * (ct - 1) / 2)

  if t < 1 then table.clear(self.geometry) end

  g.setColor(0, 0, 0, 80 * math.clamp(upgradeFactor, 0, 1))
  g.rectangle('fill', 0, 0, ctx.view.frame.width, ctx.view.frame.height)

  for i = 1, self.count do
    local selectFactor = math.max(self.selectFactor[i], upgradeFactor)
    local bg = data.media.graphics.hudMinion
    local w, h = bg:getDimensions()
    local scale = (.25 + (.2 * upgradeFactor)) * v / w
    local yy = v * (.01 + (.00 * upgradeFactor))
    local alpha = .65 + selectFactor * .35
    local font = g.setFont('sourcesanspro', .04 * scale * v)

    -- Backdrop
    g.setColor(255, 255, 255, 200 * alpha)
    g.draw(bg, xx, yy, 0, scale, scale, w / 2, 0)

    -- Animation
    self.animations[i]:draw(xx, yy + .2 * scale * v)

    -- Text
    local unit = data.unit[p.deck[i].code]
    g.setColor(255, 255, 255, 200 * alpha)
    g.printCenter(unit.name--[[unit.name:gsub('%w*', string.upper)]], math.round(xx), math.round(yy + (.05 * v * scale)))
    g.setColor(0, 0, 0, 200 * alpha)
    g.printCenter(unit.cost, xx - (.185 * v * scale) + 1, yy + (.2175 * v * scale) + 1)
    
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
          ctx.upgrades.unlock(who, what)
          ctx.hud.tooltip = nil
        end
      end
    end
  end
end

function HudUnits:ready()
  local p = ctx.players:get(ctx.id)

  self.count = #p.deck
  self.selectFactor = {}
  self.animations = {}

  for i = 1, self.count do
    self.selectFactor[i] = 0
    local scale = data.animation[p.deck[i].code].scale / 2
    self.animations[i] = data.animation[p.deck[i].code]({scale = scale})
    self.animations[i]:set('idle')
  end
end
