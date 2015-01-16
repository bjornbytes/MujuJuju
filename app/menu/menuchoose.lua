local g = love.graphics

MenuChoose = class()

function MenuChoose:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    minions = function()
      local u, v = ctx.u, ctx.v
      local minions = config.starters
      local size = .1 * v
      local inc = (size * 2) + .1 * v
      local x = u * .5 - inc * ((#minions - 1) / 2)
      local y = .65 * v
      local res = {}
      for i = 1, #minions do
        table.insert(res, {x, y, size})
        x = x + inc
      end
      return res
    end,

    colors = function()
      local u, v = ctx.u, ctx.v
      local ct = #config.player.colorOrder
      local width = .08 * v * 1.3
      local inc = width + .02 * v
      local x = u * .5 - (inc * (ct - 1) / 2)
      local res = {}
      for name, color in pairs(config.player.colors) do
        table.insert(res, {x - width / 2, v * .26, width, .08 * v})
        x = x + inc
      end
      return res
    end
  }
  
  self.active = false
end

function MenuChoose:update()
  self.active = ctx.page == 'choose'

  if self.active then
    local mx, my = love.mouse.getPosition()
    local minions = self.geometry.minions
    for i = 1, #minions do
      if math.insideCircle(mx, my, unpack(minions[i])) then
        ctx.tooltip:setUnitTooltip(config.starters[i])
        break
      end
    end
  end
end

function MenuChoose:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  g.setFont('mesmerize', .04 * v)

  if #ctx.user.name == 0 then g.setColor(255, 0, 0)
  else g.setColor(255, 255, 255) end
  g.printCenter('Enter your name', u * .5, v * .06)

  g.setColor(255, 255, 255)
  g.printCenter(ctx.user.name, u * .5, v * .12)

  local fontHeight = g.getFont():getHeight()
  local lineX = u * .5 + g.getFont():getWidth(ctx.user.name) / 2 + 1
  g.line(lineX, v * .12 - fontHeight / 2, lineX, v * .12 + fontHeight / 2)

  g.printCenter('Pick your color', u * .5, v * .21)

  local colors = self.geometry.colors
  for i = 1, #colors do
    local name = config.player.colorOrder[i]
    local color = config.player.colors[name]
    g.setColor(color[1] * 255, color[2] * 255, color[3] * 255)
    g.rectangle('fill', unpack(colors[i]))
    if ctx.user.color == name then
      g.setColor(255, 255, 255)
      g.rectangle('line', unpack(colors[i]))
    end
  end

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', u * .2, v * .38, u * .6, v * .42)

  g.setFont('mesmerize', .08 * v)
  g.setColor(255, 255, 255)
  local str = 'Choose your minion'
  g.printShadow('Choose your minion', .5 * u - g.getFont():getWidth(str) / 2, .4 * v)

  local minions = self.geometry.minions
  for i = 1, #minions do
    local code = config.starters[i]
    local x, y, r = unpack(minions[i])
    local cw, ch = ctx.unitCanvas:getDimensions()
    ctx.unitCanvas:clear(0, 0, 0, 0)
    ctx.unitCanvas:renderTo(function()
      ctx.animations[code]:draw(cw / 2, ch / 2)
    end)
    g.draw(ctx.unitCanvas, x, y, 0, 1, 1, cw / 2, ch / 2)
  end
end

function MenuChoose:keypressed(key)
  if not self.active then return end
  if key == 'backspace' then ctx.user.name = ctx.user.name:sub(1, -2) end
end

function MenuChoose:mousepressed(mx, my, b)
  if not self.active then return end
  if b == 'l' and #ctx.user.name > 0 then
    local minions = self.geometry.minions
    for i = 1, #minions do
      local x, y, r = unpack(minions[i])
      if math.distance(mx, my, x, y) < r then
        for j = 1, #ctx.user.minions do
          if ctx.user.minions[j] == config.starters[i] then table.remove(ctx.user.minions, j) break end
        end
        ctx.user.deck.minions = {config.starters[i]}
        ctx.user.deck.runes[1] = {}
        saveUser(ctx.user)
        self.active = false
        ctx.page = 'main'
        ctx.animations.muju:set('summon')
        ctx.sound:play('summon2')
      end
    end

    local colors = self.geometry.colors
    for i = 1, #colors do
      if math.inside(mx, my, unpack(colors[i])) then
        ctx.user.color = config.player.colorOrder[i]
      end
    end
  end
end

function MenuChoose:mousereleased(mx, my, b)

end

function MenuChoose:textinput(char)
  if not self.active then return end
  if #ctx.user.name < 16 and char:match('%a*%d*') then
    ctx.user.name = ctx.user.name .. char
  end
end
