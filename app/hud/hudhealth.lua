HudHealth = class()

local g = love.graphics

local green = {50, 230, 50}
local red = {255, 0, 0}
local purple = {200, 80, 255}
local orange = {255, 185, 40}

local function makeBin()
  return {units = {}, offsety = 0}
end

local function bar(x, y, hard, soft, color, width, height)
  x, y = ctx.view:screenPoint(x, y)
  width = width * ctx.view.scale

  g.setColor(255, 255, 255, 80)
  local w, h = data.media.graphics.healthbarFrame:getDimensions()
  local scale = width / w
  local xx = math.round(x - width / 2)
  local yy = math.round(y)

  g.draw(data.media.graphics.healthbarFrame, xx, yy, 0, scale, scale)

  xx = xx + math.round(3 * scale)
  yy = yy + math.round(3 * scale)

  local barHeight = data.media.graphics.healthbarGradient:getHeight()
  g.setColor(color[1], color[2], color[3], 100)
  g.draw(data.media.graphics.healthbarBar, xx, yy, 0, hard * math.round(width - 6 * scale), scale)

  if soft then
    g.setColor(color[1], color[2], color[3], 50)
    g.draw(data.media.graphics.healthbarBar, xx, yy, 0, soft * math.round(width - 6 * scale), scale)
  end

  g.setBlendMode('additive')
  g.setColor(255, 255, 255, 180)
	--g.draw(data.media.graphics.healthbarGradient, xx, yy, 0, 1 * math.round(width - 6 * scale), scale)
  g.setBlendMode('alpha')
end

function HudHealth:init()
  self.bins = {}
  self.unitBins = {}
  self.unitBarPrevY = setmetatable({}, {__mode = 'k'})
  self.unitBarY = setmetatable({}, {__mode = 'k'})
end

function HudHealth:update()
  local minx = {}
  local maxx = {}
  local touched = {}

  ctx.units:each(function(unit)
    local code = unit.class.code
    minx[code] = math.min(minx[code] or math.huge, unit.x)
    maxx[code] = math.max(maxx[code] or -math.huge, unit.x)
    touched[unit] = true
  end)

  ctx.units:each(function(unit)
    local code = unit.class.code
    self.bins[code] = self.bins[code] or {}
    local bins = self.bins[code]
    local binWidth = (maxx[code] - minx[code])
    binWidth = binWidth == 0 and 1 or binWidth
    local binCount = 1 + math.floor(binWidth / 86)
    local bin = math.ceil(((unit.x - minx[code] + 1) / (binWidth + 1)) * binCount)

    if bin ~= self.unitBins[unit] then
      self:debin(unit)
      bins[bin] = bins[bin] or makeBin()
      table.insert(bins[bin].units, unit)
    end

    self.unitBins[unit] = bin
  end)

  table.each(self.unitBins, function(v, unit)
    if not touched[unit] then self:debin(unit) end
  end)

  local frame = data.media.graphics.healthbarFrame
  local w, h = frame:getDimensions()
  local scale = 80 / w
  local height = h * scale + 4
  table.each(self.bins, function(binList, code)
    for i = 1, #binList do
      if binList[i] then
        local totalx = 0
        for k = 1, #binList[i].units do totalx = totalx + binList[i].units[k].x end
        local meanx = totalx / (#binList[i].units == 0 and 1 or #binList[i].units)
        table.each(self.bins, function(otherBinList, otherCode)
          if code ~= otherCode then
            for j = 1, #otherBinList do
              if otherBinList[j] then
                otherBinList[j].offsetY = 0
                local othertotalx = 0
                for k = 1, #otherBinList[j].units do othertotalx = othertotalx + otherBinList[j].units[k].x end
                local othermeanx = othertotalx / (#otherBinList[j].units == 0 and 1 or #otherBinList[j].units)
                if meanx - 40 <= othermeanx + 40 and othermeanx - 40 <= meanx + 40 then
                  binList[i].offsetY = otherBinList[j].offsetY + (height * #otherBinList[j].units)
                  return true
                end
              end
            end
          end
        end)
      end
    end
  end)

  local frame = data.media.graphics.healthbarFrame
  local w, h = frame:getDimensions()
  local scale = 80 / w
  ctx.units:each(function(unit)
    local startY = math.round(ctx.map.height - ctx.map.groundHeight - unit.height * 2 + (h * scale) + .5)
    self.unitBarY[unit] = self.unitBarY[unit] or startY
  end)

  table.each(self.unitBarY, function(_, unit)
    if not self.unitBins[unit] then
      self.unitBarY[unit] = nil
      return
    end

    local binIndex = nil
    for i = 1, #self.bins[unit.class.code][self.unitBins[unit]].units do
      if self.bins[unit.class.code][self.unitBins[unit]].units[i] == unit then
        binIndex = i
        break
      end
    end

    local targetY = math.round(ctx.map.height - ctx.map.groundHeight - unit.height * 2 - (binIndex - 1) * (data.media.graphics.healthbarFrame:getHeight() * scale + .5))
    targetY = targetY - (self.bins[unit.class.code][self.unitBins[unit]].offsetY or 0)
    self.unitBarPrevY[unit] = self.unitBarY[unit] or startY
    self.unitBarY[unit] = self.unitBarY[unit] and math.lerp(self.unitBarY[unit], targetY, math.min(200 * tickRate, 1)) or startY
  end)
end

function HudHealth:debin(unit)
  local code = unit.class.code
  local bins = self.bins[code]
  local unitbin = self.unitBins[unit]
  if bins and unitbin then
    for i = 1, #bins[unitbin].units do
      if bins[unitbin].units[i] == unit then
        table.remove(bins[unitbin].units, i)
        self.unitBins[unit] = nil
        return
      end
    end
  end
end

function HudHealth:draw()
  if ctx.ending then return end

  local p = ctx.player
  local vx, vy = math.lerp(ctx.view.prevx, ctx.view.x, tickDelta / tickRate), math.lerp(ctx.view.prevy, ctx.view.y, tickDelta / tickRate)

  ctx.players:each(function(player)
    local x, y, hard, soft = player:getHealthbar()
    local color = (p and player.team == p.team) and green or red
    bar(x, y - 20, hard, soft, color, 100, 3)
  end)

  ctx.shrines:each(function(shrine)
    local color = (p and shrine.team == p.team) and green or red
    local x, y, hard, soft = shrine:getHealthbar()
    local w, h = 120 + (60 * (shrine.hurtFactor)), 4 + (1 * shrine.hurtFactor)
    bar(x, y - 65, hard, soft, color, w, h)
  end)

  --[[ctx.units:each(function(unit)
    local x, y, hard, soft = unit:getHealthbar()
    local elitebuffs = unit.buffs:buffswithtag('elite')
    local location = math.floor(unit.x)
    stack(t, location, unit.width, 2)

    if next(elitebuffs) then
      local string = ''
      table.each(elitebuffs, function(buff)
        string = string .. buff.name .. ' '
      end)
      g.setfont('pixel', 8)
      g.setcolor(0, 0, 0)
      g.printcenter(string, x + 1, (y - 30 - 5 * t[location]) - 12 + 1)
      g.setcolor(255, 255, 255)
      g.printcenter(string, x, (y - 30 - 5 * t[location]) - 12)
    end

    local color = (p and unit.team == p.team) and green or red
    bar(x, y - 30 - 5 * t[location], hard, soft, color, 80, 3)
  end)]]

  table.each(self.bins, function(binList)
    table.each(binList, function(bin)
      local totalx = 0
      for j = 1, #bin.units do totalx = totalx + bin.units[j].x end

      local meanx = totalx / (#bin.units == 0 and 1 or #bin.units)

      -- Bar
      local x, y = meanx, ctx.map.height - ctx.map.groundHeight - 150
      local width = 80
      local color = (p and bin.units[1] and bin.units[1].team == p.team) and green or red
      x, y = ctx.view:screenPoint(x, y)
      width = width * ctx.view.scale

      local frame = data.media.graphics.healthbarFrame
      local w, h = frame:getDimensions()
      local scale = width / w
      local xx = math.round(x - width / 2)
      local yy = math.round(y)

      for j = 1, #bin.units do
        local unit = bin.units[j]
        local barY = math.lerp(self.unitBarPrevY[unit], self.unitBarY[unit], tickDelta / tickRate)
        g.setColor(255, 255, 255, 80 * bin.units[j].alpha)
        g.draw(frame, xx, barY, 0, scale, scale)
      end

      xx = xx + math.round(3 * scale)
      yy = yy + math.round(3 * scale)

      local barWidth = math.round(width - 6 * scale)
      local barHeight = data.media.graphics.healthbarGradient:getHeight()

      for j = 1, #bin.units do
        local unit = bin.units[j]
        g.setColor(color[1], color[2], color[3], 200 * unit.alpha)
        local y = self.unitBarY[unit] + math.round(3 * scale)
        --local y = math.round(yy + (j - 1) * (data.media.graphics.healthbarFrame:getHeight() * scale + 1.5))
        local _, _, hard, soft = unit:getHealthbar()
        g.setColor(color[1], color[2], color[3], 100 * unit.alpha)
        g.draw(data.media.graphics.healthbarBar, xx, y, 0, hard * barWidth, scale)
        if soft then
          g.setColor(color[1], color[2], color[3], 50)
          g.draw(data.media.graphics.healthbarBar, xx, y, 0, soft * barWidth, scale)
        end

        local elitebuffs = unit.buffs:buffsWithTag('elite')
        if next(elitebuffs) then
          local string = ''
          table.each(elitebuffs, function(buff)
            string = string .. buff.name .. ' '
          end)
          g.setFont('pixel', 8)
          local texty = y + data.media.graphics.healthbarBar:getHeight() * scale / 2 - g.getFont():getHeight() / 2
          g.setColor(0, 0, 0)
          g.printCenter(string, x + 1, texty + 1)
          g.setColor(255, 255, 255)
          g.printCenter(string, x, texty)
        end
      end

      g.setBlendMode('additive')
      for j = 1, #bin.units do
        local y = self.unitBarY[bin.units[j]] + math.round(3 * scale)
        g.setColor(255, 255, 255, 180)
        --g.draw(data.media.graphics.healthbarGradient, xx, y, 0, 1 * math.round(width - 6 * scale), scale)
      end
      g.setBlendMode('alpha')
    end)
  end)
end
