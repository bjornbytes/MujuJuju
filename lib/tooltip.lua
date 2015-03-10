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
  local xx = math.min(mx + 16 * love.window.getPixelScale(), u - self.textWidth - 14)
  local yy = math.min(my + 16 * love.window.getPixelScale(), v - (self.textHeight + 9))
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

    ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
  end

  self.active = true
end

function Tooltip:setUnitTooltip(class, basic)
  if type(class) == 'string' then class = data.unit[class] end
  local pieces = {}
  table.insert(pieces, '{title}{white}' .. class.name .. '{normal}')
  table.insert(pieces, '{whoCares}' .. class.description .. '{white}')
  if basic then
    table.insert(pieces, '')
    return self:setTooltip(table.concat(pieces, '\n'))
  end

  table.insert(pieces, '')
  for _, stat in ipairs({'health', 'damage', 'attackSpeed', 'speed', 'spirit', 'haste'}) do
    local base = class[stat]
    local actual = Unit.getStat(class, stat)
    local label = stat:capitalize()
    local extra = ''
    local color = '{white}'
    if stat == 'attackSpeed' then
      label = 'Attack Speed'
      if actual > 0 then
        color = '{green}'
        extra = ' {white}({whoCares}' .. math.round(base * 100) / 100 .. ' + {green}' .. math.round(actual * 100) .. '%{white})'
      end
      local actual = math.max(base - (base * actual), .4)
      table.insert(pieces, '{whoCares}{bold}' .. label .. '{white}{normal}: ' .. color .. math.round(actual * 100) / 100 .. extra)
    elseif stat == 'haste' then
      if actual > 0 then
        color = '{green}'
        extra = ' {white}({whoCares}100% + {green}' .. math.round(actual * 100) .. '%{white})'
      end
      table.insert(pieces, '{whoCares}{bold}' .. label .. '{white}{normal}: ' .. color .. math.round((base + actual) * 100) .. '%' .. extra)
    else
      if base ~= actual then
        color = '{green}'
        extra = ' {white}({whoCares}' .. math.round(base) .. ' + {green}' .. math.round(actual - base) .. '{white})'
      end
      table.insert(pieces, '{whoCares}{bold}' .. label .. '{white}{normal}: ' .. color .. math.round(actual) .. extra)
    end
  end
  table.insert(pieces, '')
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

  local bonuses = upgrade.bonuses and upgrade:bonuses(data.unit[who])
  if bonuses and type(bonuses) == 'table' and #bonuses > 0 then
    table.insert(pieces, '')
    table.insert(pieces, '{white}Bonuses')
    for i = 1, #bonuses do
      local bonus = bonuses[i]
      table.insert(pieces, '{white}{bold}' .. bonus[1] .. '{normal}: ' .. '{green}+' .. bonus[2] .. '{white} ' .. bonus[3])
    end
  end

  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setMagicShrujuTooltip(shruju)
  local pieces = {}
  table.insert(pieces, '{purple}{title}' .. shruju.name .. '{white}{normal}')
  table.insert(pieces, '{white}' .. shruju.description)
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setRuneTooltip(rune)
  local formatters = {
    percent = function(x, stat)
      return '+' .. math.round(x * 100) .. '% ' .. stat
    end,

    flat = function(x, stat)
      return '+' .. math.round(x) .. ' ' .. stat
    end,

    time = function(x, stat)
      return '+' .. math.round(x * 10) / 10 .. 's ' .. stat
    end
  }

  local pieces = {}
  table.insert(pieces, '{white}{title}' .. rune.name .. '{normal}')
  if rune.attributes then
    table.each(rune.attributes, function(amount, attribute)
      table.insert(pieces, '+' .. amount .. ' to ' .. attribute:capitalize())
    end)
  elseif rune.stats then
    table.each(rune.stats, function(amount, stat)
      if stat == 'attackSpeed' then
        table.insert(pieces, '+' .. math.round(amount * 100) .. '% to ' .. ' attack speed')
      elseif stat == 'haste' then
        table.insert(pieces, '+' .. math.round(amount * 100) .. '% to ' .. ' haste')
      else
        table.insert(pieces, '+' .. math.round(amount) .. ' to ' .. stat:capitalize())
      end
    end)
  elseif rune.unit and rune.abilities then
    table.insert(pieces, rune.unit:capitalize() .. ' only')
    local ability = next(rune.abilities)
    local stat, amount = next(rune.abilities[ability])
    local str = '+' .. math.round(amount) .. ' to ' .. stat
    local formatter = config.runes.abilityFormatters
    formatter = formatter[rune.unit] and formatter[rune.unit][ability] and formatter[rune.unit][ability][stat]
    if formatter then
      local key, a, b, c, d = unpack(formatter)
      str = formatters[key](amount, a, b, c, d)
    end
    table.insert(pieces, data.unit[rune.unit].upgrades[ability].name .. ': ' .. str)
  end
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setAttributeTooltip(attribute, unit)
  local p = ctx.player
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. attribute:capitalize() .. '{normal}')
  table.insert(pieces, '{whoCares}' .. config.attributes.descriptions[attribute] .. '{white}')
  table.insert(pieces, '')
  if unit then
    if type(unit) == 'string' then unit = data.unit[unit] end
    local level = unit.attributes[attribute]
    table.each(config.attributes[attribute], function(amount, stat)
      local value = amount
      local total = amount * level
      if stat == 'attackSpeed' then
        stat = 'attack speed'
        value = (amount * 100) .. '%'
        total = ((amount * level) * 100) .. '%'
      elseif stat == 'haste' then
        value = (amount * 100) .. '%'
        total = ((amount * level) * 100) .. '%'
      end
      table.insert(pieces, '+' .. value .. ' ' .. stat .. ' per level {green}(' .. (total) .. '){white}')
    end)
    local cost = 30 + 20 * level
    local color = p.juju >= cost and '{green}' or '{red}'
    table.insert(pieces, color .. cost .. ' juju')
  end

  table.insert(pieces, '')

  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setHatTooltip(hat)
  local pieces = {}
  table.insert(pieces, '{title}{white}' .. hat:capitalize())
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
