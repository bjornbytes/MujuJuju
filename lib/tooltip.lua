require 'lib/typo'
local rich = require 'lib/deps/richtext'
local g = love.graphics

Tooltip = class()
Tooltip.maxWidth = .3
function Tooltip:init()
  self.richOptions = {
    whoCares = {225, 225, 225},
    white = {255, 255, 255},
    red = {255, 100, 100},
    green = {100, 255, 100},
    purple = {147, 96, 200}
  }

  self.active = false
  self.tooltip = nil
  self.tooltipText = nil

  self.textWidth = 0
  self.textHeight = 0
  self.blurCanvas = g.newCanvas(400, 300)
  self.blurBackCanvas = g.newCanvas(400, 300)

  self.cursorX, self.cursorY = love.mouse.getPosition()
  self.prevCursorX = self.cursorX
  self.prevCursorY = self.cursorY

  self:resize()
end

function Tooltip:update()
  local mx, my

  if ctx.view then
    mx = ctx.view:frameMouseX()
    my = ctx.view:frameMouseY()
  else
    mx, my = love.mouse.getPosition()
  end

  self.prevCursorX = self.cursorX
  self.prevCursorY = self.cursorY
  self.cursorX = math.lerp(self.cursorX, mx, 12 * ls.tickrate)
  self.cursorY = math.lerp(self.cursorY, my, 12 * ls.tickrate)
end

function Tooltip:draw()
  if not self.active then self.tooltipText = nil return end

  local u, v = self:getUV()
  local mx = math.lerp(self.prevCursorX, self.cursorX, ls.accum / ls.tickrate)
  local my = math.lerp(self.prevCursorY, self.cursorY, ls.accum / ls.tickrate)
  local xx = math.min(mx + 16, u - self.textWidth - 14)
  local yy = math.min(my + 16, v - (self.textHeight + 9))
  g.setColor(255, 255, 255, 100)
  g.draw(self.blurCanvas, xx - 96, yy - 96, 0, 2, 2)
  g.setColor(30, 50, 70, 240)
  g.rectangle('fill', xx, yy, self.textWidth + 14, self.textHeight + 9)
  g.setColor(10, 30, 50, 255)
  g.rectangle('line', xx + .5, yy + .5, self.textWidth + 14, self.textHeight + 9)
  self.tooltip:draw(xx + 8, yy + 4)
end

function Tooltip:setTooltip(str)
  local u, v = self:getUV()
  local raw = str:gsub('{%a+}', '')
  if str ~= self.tooltipText then
    g.setFont(self.richOptions.normal)
    self.tooltip = rich:new({str, u * self.maxWidth, self.richOptions}, {255, 255, 255})
    self.tooltipText = str

    local raw = self.tooltipText:gsub('{%a+}', '')
    local normalFont = self.richOptions.normal
    local titleFont = self.richOptions.title
    g.setFont(self.richOptions.normal)
    local titleLine = raw:sub(1, raw:find('\n'))
    local normalText = raw:sub(raw:find('\n') + 1) -- TODO memoize in :setTooltip
    local textWidth, lines = normalFont:getWrap(normalText, u * self.maxWidth)
    local titleWidth, titleLines = titleFont:getWrap(titleLine, u * self.maxWidth)
    self.textWidth = math.max(textWidth, titleWidth)
    self.textHeight = titleLines * titleFont:getHeight() + lines * normalFont:getHeight()

    g.setCanvas(self.blurCanvas)
    self.blurCanvas:clear(0, 0, 0, 0)
    self.blurBackCanvas:clear(0, 0, 0, 0)
    g.setColor(0, 0, 0)
    g.rectangle('fill', 50, 50, (self.textWidth + 14) / 2, (self.textHeight + 9) / 2)

    g.setColor(255, 255, 255)
    for i = 1, 3 do
      data.media.shaders.horizontalBlur:send('amount', .003)
      data.media.shaders.verticalBlur:send('amount', .003 * 4/3)
      g.setCanvas(self.blurBackCanvas)
      g.setShader(data.media.shaders.horizontalBlur)
      g.draw(self.blurCanvas)
      g.setCanvas(self.blurCanvas)
      g.setShader(data.media.shaders.verticalBlur)
      g.draw(self.blurBackCanvas)
    end

    g.setCanvas()
    g.setShader()
  end

  self.active = true
end

function Tooltip:setUnitTooltip(code)
  if not code then return end
  local unit = data.unit[code]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. unit.name .. '{normal}')
  table.insert(pieces, '{whoCares}' .. unit.description)
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setUpgradeTooltip(who, what)
  local p = ctx.player
  local pieces = {}
  local upgrade = data.unit[who].upgrades[what]
  table.insert(pieces, '{white}{title}' .. upgrade.name .. '{normal}')
  table.insert(pieces, '{whoCares}' .. upgrade.description .. '\n')
  local function getValue(level)
    local value = ''
    if upgrade.values and (type(upgrade.values) == 'function' or upgrade.values[level]) then
      value = type(upgrade.values) == 'function' and upgrade.values(upgrade, level, data.unit[who]) or upgrade.values[level]
      value = value or ''
    end
    return value == '' and value or '{normal}: ' .. value
  end
  table.insert(pieces, '{white}{bold}Level ' .. upgrade.level .. getValue(upgrade.level))
  if upgrade.level >= upgrade.maxLevel then
    table.insert(pieces, '{whoCares}{normal}Max Level')
  else
    local value = getValue(upgrade.level + 1)
    if value == '' then value = '{normal}: Level ' .. upgrade.level + 1 end
    table.insert(pieces, '{white}{bold}Next Level' .. value)
    local color = p.juju >= upgrade.costs[upgrade.level + 1] and '{green}' or '{red}'
    table.insert(pieces, color .. upgrade.costs[upgrade.level + 1] .. ' juju')
    if upgrade.prerequisites then
      for name, min in pairs(upgrade.prerequisites) do
        local color = data.unit[who].upgrades[name].level >= min and '{green}' or '{red}'
        local points = (min == 1) and 'point' or 'points'
        table.insert(pieces, color .. min .. ' ' .. points .. ' in ' .. data.unit[who].upgrades[name].name:capitalize())
      end
    end
  end

  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setShrujuTooltip(shruju)
  if type(shruju) == 'string' then shruju = data.shruju[shruju] end
  local pieces = {}
  table.insert(pieces, '{title}' .. (shruju.effect and '{purple}' or '{white}') .. shruju.name .. '{normal}')
  table.insert(pieces, '{whoCares}' .. shruju.description .. '{white}\n')
  if shruju.effect then table.insert(pieces, '{purple}' .. shruju.effect.name .. ' - ' .. shruju.effect.description) end
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setMagicShrujuTooltip(shruju)
  local pieces = {}
  table.insert(pieces, '{purple}{title}' .. shruju.name .. '{white}{normal}')
  table.insert(pieces, '{white}' .. shruju.description)
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setRuneTooltip(rune)
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. rune.name .. '{normal}')
  if rune.attributes then
    table.each(rune.attributes, function(amount, attribute)
      table.insert(pieces, '+' .. amount .. ' to ' .. attribute:capitalize())
    end)
  elseif rune.stats then
    table.each(rune.stats, function(amount, stat)
      table.insert(pieces, '+' .. math.round(amount) .. ' to ' .. stat:capitalize())
    end)
  elseif rune.unit and rune.abilities then
    table.insert(pieces, rune.unit:capitalize() .. ' only')
    local ability = next(rune.abilities)
    local stat, amount = next(rune.abilities[ability])
    table.insert(pieces, '+' .. math.round(amount) .. ' to ' .. ability:capitalize() .. ' ' .. stat)
  end
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setAttributeTooltip(attribute, unit)
  local p = ctx.player
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. attribute:capitalize() .. '{normal}')
  if unit then
    if type(unit) == 'string' then unit = data.unit[unit] end
    local level = unit.attributes[attribute]
    table.each(config.attributes[attribute], function(amount, stat)
      table.insert(pieces, '+' .. amount .. ' ' .. stat .. ' per level {green}(' .. (amount * level) .. '){white}')
    end)
    local cost = 30 + 10 * level
    local color = p.juju >= cost and '{green}' or '{red}'
    table.insert(pieces, color .. cost .. ' juju')
  end

  table.insert(pieces, '')

  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:resize()
  local u, v = self:getUV()
  self.richOptions.title = Typo.font('mesmerize', .0376 * v)
  self.richOptions.normal = Typo.font('mesmerize', .02 * v)
  self.richOptions.bold = Typo.font('mesmerize', .02 * v)
end

function Tooltip:dirty()
  self.active = false
end

function Tooltip:getUV()
  if isa(ctx, Menu) then return ctx.u, ctx.v
  elseif isa(ctx, Game) then
    if ctx.hud then
      return ctx.hud.u, ctx.hud.v
    else
      return ctx.view.frame.width, ctx.view.frame.height
    end
  end
end
