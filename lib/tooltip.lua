require 'lib/typo'
local rich = require 'lib/deps/richtext/richtext'
local g = love.graphics

Tooltip = class()
Tooltip.maxWidth = .35
Tooltip.richOptions = {
  title = g.setFont('mesmerize', 24),
  bold = g.setFont('mesmerize', 14),
  normal = g.setFont('mesmerize', 14),
  white = {255, 255, 255},
  whoCares = {230, 230, 230},
  red = {255, 100, 100},
  green = {100, 255, 100},
  purple = {147, 96, 200}
}

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

function Tooltip:setUnitTooltip(code)
  local unit = data.unit[code]
  local pieces = {}
  table.insert(pieces, '{white}{title}' .. unit.name .. '{normal}')
  table.insert(pieces, '{whoCares}' .. unit.description)
  return setTooltip(table.concat(pieces, '\n'))
end

function Tooltip:setUpgradeTooltip(unit, code)
  
end

function Tooltip:setShrujuTooltip(shruju)
  if type(shruju) == 'string' then shruju = data.shruju[shruju] end
end

function Tooltip:setRuneTooltip(rune)

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
