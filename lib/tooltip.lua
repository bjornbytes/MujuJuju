local rich = require 'lib/deps/richtext/richtext'
local g = love.graphics

Tooltip = class()
Tooltip.maxWidth = .35

function Tooltip:init()
  self.active = false
  self.tooltip = nil
  self.tooltipText = nil
  self.x = nil
  self.y = nil
  self.prevx = self.x
  self.prevy = self.y
end

function Tooltip:update()
  self.active = false
  self.prevx = self.x
  self.prevy = self.y

  local mx, my = love.mouse.getPosition()
  self.x = self.x and math.lerp(self.x, mx, math.min(15 * tickRate, 1)) or mx
  self.y = self.y and math.lerp(self.y, my, math.min(15 * tickRate, 1)) or my

  if not self.richOptions then self:resize() end
end

function Tooltip:draw()
  if self.active then
    local u, v = self:getUV()
    local x = (self.prevx and self.x) and math.lerp(self.prevx, self.x, tickDelta / tickRate) or love.mouse.getX()
    local y = (self.prevy and self.y) and math.lerp(self.prevy, self.y, tickDelta / tickRate) or love.mouse.getY()
    local font = Typo.font('mesmerize', .023 * v)
    local textWidth, lines = font:getWrap(self.tooltipText, self.maxWidth * u)
    local xx = math.round(math.min(x + 8, u - textWidth - (.03 * u)))
    local yy = math.round(math.min(y + 8, v - (lines * font:getHeight()) - 7 - (.03 * u)))
    g.setFont(font)
    g.setColor(30, 50, 70, 240)
    g.rectangle('fill', xx, yy, textWidth + 14, lines * font:getHeight() + 16 + 5)
    g.setColor(10, 30, 50, 255)
    g.rectangle('line', xx + .5, yy + .5, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
    self.tooltip:draw(xx + 8, yy + 4)
  end
end

function Tooltip:setTooltip(str)
  local u, v = self:getUV()
  self.tooltip = rich:new({str, u * self.maxWidth, self.richOptions}, {255, 255, 255})
  self.tooltipText = str:gsub('{%a+}', '')
  self.active = true
end

function Tooltip:unitTooltip(code)
  local unit = data.unit[code]
  if not unit then return end
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. unit.name .. '{normal}')
  table.insert(pieces, 'This unit is actually really cool.')
  return table.concat(pieces, '\n')
end

function Tooltip:runeTooltip(id)
  local rune = runes[id]
  if not rune then return end
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. rune.name .. '{normal}')
  table.insert(pieces, rune.description)
  return table.concat(pieces, '\n')
end

function Tooltip:abilityTooltip(code, index)
  local ability = data.ability[code][data.unit[code].abilities[index]]
  if not ability then return end
  local description = self:substitutions(ability)
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. ability.name .. '{normal}')
  table.insert(pieces, description)
  table.insert(pieces, '\nCost: ' .. ctx.upgrades.costs.ability)
  return table.concat(pieces, '\n')
end

function Tooltip:abilityUpgradeTooltip(code, ability, index)
  local upgrade = data.ability[code][data.unit[code].abilities[ability]].upgrades[index]
  if not upgrade then return end
  local description = self:substitutions(upgrade)
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. upgrade.name .. '{normal}')
  table.insert(pieces, description)
  table.insert(pieces, '\nCost: ' .. ctx.upgrades.costs.abilityUpgrade)
  return table.concat(pieces, '\n')
end

function Tooltip:substitutions(object)
  local lastvar = nil
  local description = object.description:gsub('%$(%w+)', function(var)
    if var == 's' then return object[lastvar] ~= 1 and 's' or '' end
    lastvar = var
    return object[var]
  end)
  description = description:gsub('%%(%w+)', function(var)
    return object[var] * 100 .. '%'
  end)
  return description
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
