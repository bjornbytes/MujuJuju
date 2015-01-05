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

        local yy = (.15 * upgradeFactor) * v + (.25 * v)
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
        local str = ctx.upgrades.makeTooltip(who, what)
        local raw = str:gsub('{%a+}', '')
        if not ctx.hud.tooltip or ctx.hud.tooltipRaw ~= raw then
          ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
          ctx.hud.tooltipRaw = raw
        end
        ctx.hud.tooltipHover = true
      end
    end
  end

	for i = 1, #self.selectFactor do
    self.prevSelectFactor[i] = self.selectFactor[i]
		self.selectFactor[i] = math.lerp(self.selectFactor[i], p.selected == i and 1 or 0, 8 * tickRate)
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
        local rune = p.deck[i].runes[j]
        local str = '{white}{title}' .. rune.name .. '{normal}\n'
        if rune.stat then
          str = str .. '+' .. math.round(rune.amount or rune.scaling) .. ' ' .. rune.stat:capitalize() .. (rune.scaling and ' per second' or '') .. '\n'
        elseif rune.upgrade then
          local name = nil
          for i = 1, #data.unit do
            local upgrade = data.unit[i].upgrades[rune.upgrade]
            if upgrade then name = upgrade.name break end
          end
          str = str .. '+1 to ' .. name:capitalize() .. '\n'
        end
        local raw = str:gsub('{%a+}', '')
        if not ctx.hud.tooltip or ctx.hud.tooltipRaw ~= raw then
          ctx.hud.tooltip = rich:new({str, 300, ctx.hud.richOptions})
          ctx.hud.tooltipRaw = raw
        end
        ctx.hud.tooltipHover = true
      end
      runex = runex + runeInc
    end
    xx = xx + inc
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
    local selectFactor = math.lerp(self.prevSelectFactor[i], self.selectFactor[i], tickDelta / tickRate)
    local bg = data.media.graphics.hud.minion
    local w, h = bg:getDimensions()
    local scale = (.25 + (.12 * upgradeFactor) + (.02 * selectFactor)) * v / w
    local yy = v * (.01 * selectFactor)
    local alpha = .45 + selectFactor * .35

    -- Backdrop
    g.setColor(255, 255, 255, 255 * alpha)
    g.draw(bg, xx, yy, 0, scale, scale, w / 2, 0)

    -- Animation
    self.canvas[i]:clear(0, 0, 0, 0)
    g.setCanvas(self.canvas[i])
    self.animations[i]:draw(100, 100)
    g.setCanvas()
    g.draw(self.canvas[i], xx, yy + .2 * scale * v, 0, scale, scale, 100, 100)

    -- Text
    local unit = data.unit[p.deck[i].code]
    local font = g.setFont('mesmerize', .04 * scale * v)
    g.setColor(255, 255, 255)
    g.printCenter(unit.name, math.round(xx), math.round(yy + (.05 * v * scale)))

    g.setFont('mesmerize', .04 * scale * v)
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
    local runeSize = v * .032 * scale
    local runeInc = runeSize * 3
    local runex = xx - (runeInc * (runeCount - 1) / 2)
    local runey = yy + .365 * v * scale
    g.setColor(255, 255, 255, 255 * alpha)
    for i = 1, runeCount do
      g.circle('line', runex, runey, runeSize)
      runex = runex + runeInc
    end
    
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
        else
          ctx.sound:play('misclick')
        end
      end
    end
  end
end

function HudUnits:ready()
  local p = ctx.players:get(ctx.id)

  self.count = #p.deck
  self.selectFactor = {}
  self.prevSelectFactor = {}
  self.animations = {}
  self.canvas = {}

  local animationScaleFactors = {
    bruju = 1.5,
    thuju = .85
  }

  local animationOffsets = {
    bruju = 0,
    thuju = -14
  }

  for i = 1, self.count do
    self.selectFactor[i] = 0
    self.prevSelectFactor[i] = self.selectFactor[i]
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
