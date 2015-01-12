require 'lib/typo'
local rich = require 'lib/deps/richtext'
local g = love.graphics

Tooltip = class()
Tooltip.maxWidth = .3
Tooltip.richOptions = {
  title = g.setFont('mesmerize', 24),
  bold = g.setFont('mesmerizeb', 14),
  normal = g.setFont('mesmerize', 14),
  white = {255, 255, 255},
  whoCares = {225, 225, 225},
  red = {255, 100, 100},
  green = {100, 255, 100},
  purple = {147, 96, 200}
}

function Tooltip:init()
  self.active = false
  self.tooltip = nil
  self.tooltipText = nil
  self.cursorX, self.cursorY = love.mouse.getPosition()
  self.prevCursorX = self.cursorX
  self.prevCursorY = self.cursorY
end

function Tooltip:update()
  self.active = false

  self.prevCursorX = self.cursorX
  self.prevCursorY = self.cursorY
  self.cursorX = math.lerp(self.cursorX, love.mouse.getX(), 8 * tickRate)
  self.cursorY = math.lerp(self.cursorY, love.mouse.getY(), 8 * tickRate)

  if not self.richOptions then self:resize() end
end

function Tooltip:draw()
  if self.active then
    local u, v = self:getUV()
    local mx = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate)
    local my = math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
    local raw = self.tooltipText:gsub('{%a+}', '')
    local normalFont = self.richOptions.normal
    local titleFont = self.richOptions.title
    g.setFont(self.richOptions.normal)
    local titleLine = raw:sub(1, raw:find('\n'))
    local normalText = raw:sub(raw:find('\n') + 1) -- TODO memoize in :setTooltip
    local textWidth, lines = normalFont:getWrap(normalText, u * self.maxWidth)
    local titleWidth, titleLines = titleFont:getWrap(titleLine, u * self.maxWidth)
    textWidth = math.max(textWidth, titleWidth)
    textHeight = titleLines * titleFont:getHeight() + lines * normalFont:getHeight()
    local xx = math.min(mx + 8, u - textWidth - 24)
    local yy = math.min(my + 8, v - (textHeight + 20))
    g.setColor(30, 50, 70, 240)
    g.rectangle('fill', xx, yy, textWidth + 14, textHeight + 9)
    g.setColor(10, 30, 50, 255)
    g.rectangle('line', xx + .5, yy + .5, textWidth + 14, textHeight + 9)
    self.tooltip:draw(xx + 8, yy + 4)
  else
    self.tooltipText = nil
  end
end

function Tooltip:setTooltip(str)
  local u, v = self:getUV()
  local raw = str:gsub('{%a+}', '')
  if str ~= self.tooltipText then
    g.setFont(self.richOptions.normal)
    self.tooltip = rich:new({str, u * self.maxWidth, self.richOptions}, {255, 255, 255})
    self.tooltipText = str
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
  table.insert(pieces, '{white}{bold}Level ' .. upgrade.level .. (upgrade.values[upgrade.level] and '{normal}: ' .. upgrade.values[upgrade.level] or ''))
  if not upgrade.values[upgrade.level + 1] then
    table.insert(pieces, '{whoCares}{normal}Max Level')
  else
    table.insert(pieces, '{white}{bold}Next Level{normal}: ' .. upgrade.values[upgrade.level + 1])
    local color = p.juju >= upgrade.costs[upgrade.level + 1] and '{green}' or '{red}'
    table.insert(pieces, color .. upgrade.costs[upgrade.level + 1] .. ' juju')
    if upgrade.prerequisites then
      for name, min in pairs(upgrade.prerequisites) do
        local color = data.unit[who].upgrades[name].level >= min and '{green}' or '{red}'
        local points = (min == 1) and 'point' or 'points'
        table.insert(pieces, color .. min .. ' ' .. points .. ' in ' .. name:capitalize())
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
  local effect = shruju.effect
  local pieces = {}
  table.insert(pieces, '{purple}{title}' .. effect.name .. '{white}{normal}')
  table.insert(pieces, '{purple}' .. effect.description)
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setRuneTooltip(rune)
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. rune.name .. '{normal}')
  if rune.stat then
    local amountRound = rune.scaling and .1 or 1
    local amount = math.round((rune.amount or rune.scaling) / amountRound) * amountRound
    table.insert(pieces, '+' .. amount .. ' ' .. rune.stat:capitalize() .. (rune.scaling and ' every minute' .. (ctx.timer and '({green}' .. math.round(rune.scaling * math.floor(ctx.timer * tickRate / 60) / .1) * .1 .. '{white})' or '') or ''))
  end
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setAttributeTooltip(code)
  local attribute = config.attributes[code]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. code:capitalize() .. '{normal}')
  table.insert(pieces, '{whoCares}' .. attribute.description)
  return self:setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:resize()
  local u, v = self:getUV()
  self.richOptions = {}
  self.richOptions.white = {255, 255, 255}
  self.richOptions.red = {255, 100, 100}
  self.richOptions.green = {100, 255, 100}
  self.richOptions.title = Typo.font('mesmerize', .04 * v)
  self.richOptions.normal = Typo.font('mesmerize', .023 * v)
end

function Tooltip:getUV()
  if isa(ctx, Menu) then return ctx.u, ctx.v
  elseif isa(ctx, Game) then return ctx.hud.u, ctx.hud.v end
end
