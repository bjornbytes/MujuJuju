local g = love.graphics
local tween = require 'lib/deps/tween/tween'

MenuMap = class()

function MenuMap:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    frame = function()
      local u, v = ctx.u, ctx.v
      local factor = self.factor
      local width = math.lerp(.95 * u, .98 * u, factor ^ 4)
      local height = width * (v / u)
      local x = math.lerp(u * .5, u * .5, factor)
      local y = math.lerp(-(height * .4), v * .5, factor)
      return {x - width / 2, y - height / 2, width, height}
    end,

    forest = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .327 * w, y + .814 * h, .025 * w}
    end,

    cavern = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .566 * w, y + .791 * h, .025 * w}
    end,

    tundra = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .632 * w, y + .435 * h, .025 * w}
    end,

    volcano = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .253 * w, y + .435 * h, .025 * w}
    end,

    forestTitle = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .244 * w, y + .646 * h}
    end,

    cavernTitle = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .677 * w, y + .694 * h}
    end,

    tundraTitle = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .793 * w, y + .269 * h}
    end,

    volcanoTitle = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .18 * w, y + .18 * h}
    end,

    trail1 = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .444 * w, y + .830 * h}
    end,

    trail2 = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .782 * w, y + .509 * h}
    end,

    trail3 = function()
      local x, y, w, h = unpack(self.geometry.frame)
      return {x + .439 * w, y + .469 * h}
    end
  }

  self.active = false
  self.focused = false
  self.factor = 1
  self.tweenDuration = .6
  self.tweenMethod = 'outQuint'
  self.tween = tween.new(self.tweenDuration, self, {factor = 1}, self.tweenMethod)
  self.alpha = 0
  self.prevAlpha = self.alpha
  self.nudge = 0
  self.prevNudge = self.nudge
  self.hovers = {}
  self.prevHovers = {}
end

function MenuMap:update()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  self.prevAlpha = self.alpha
  self.alpha = math.lerp(self.alpha, self.focused and 1 or 0, math.min(6 * ls.tickrate, 1))

  self.prevNudge = self.nudge
  self.nudge = math.lerp(self.nudge, my < .08 * v and 1 or 0, math.min(6 * ls.tickrate, 1))
  if self.focused then self.nudge = 0 end

  for k, v in ipairs(config.biomeOrder) do
    local hover = math.insideCircle(mx, my, unpack(self.geometry[v]))
    self.prevHovers[v] = self.hovers[v] or 0
    self.hovers[v] = math.lerp(self.hovers[v] or 0, hover and 1 or 0, math.min(10 * ls.tickrate, 1))
  end
end

function MenuMap:draw()
  if not self.active then return end

  self.tween:update(ls.dt)

  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  if self.tween.clock < self.tweenDuration then
    table.clear(self.geometry)
  end

  local alpha = math.lerp(self.prevAlpha, self.alpha, ls.accum / ls.tickrate)

  g.setColor(0, 0, 0, 80 * alpha)
  g.rectangle('fill', 0, 0, u, v)

  local x, y, w, h = unpack(self.geometry.frame)
  local image = data.media.graphics.worldmap.background
  local xscale = w / image:getWidth()
  local yscale = h / image:getHeight()
  local nudge = math.lerp(self.prevNudge, self.nudge, ls.accum / ls.tickrate)
  g.setColor(255, 255, 255)
  y = y + nudge * .1 * v
  g.draw(image, x, y, 0, xscale, yscale)

  for k, v in ipairs(config.biomeOrder) do
    local factor = math.lerp(self.prevHovers[v], self.hovers[v], ls.accum / ls.tickrate)
    local hover = math.insideCircle(mx, my, unpack(self.geometry[v]))
    local active = hover and love.mouse.isDown('l')

    if k >= 2 then
      local x, y = unpack(self.geometry['trail' .. (k - 1)])
      local image = data.media.graphics.worldmap['trail' .. (k - 1)]
      g.setColor(255, 255, 255)
      g.draw(image, x, y, 0, xscale, yscale, image:getWidth() / 2, image:getHeight() / 2)
    end

    local x, y, r = unpack(self.geometry[v])
    local image = data.media.graphics.worldmap.circle
    local scale = r * 2 / image:getWidth()
    if active then y = y + 2 end
    scale = scale * (.7 + .2 * factor)
    g.setColor(255, 255, 255)
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if self.focused then
      local image = data.media.graphics.worldmap[v]
      local x, y = unpack(self.geometry[v .. 'Title'])
      local xscale, yscale = xscale * (1 + .1 * factor), yscale * (1 + .1 * factor)
      g.setColor(255, 255, 255)
      g.draw(image, x, y, 0, xscale, yscale, image:getWidth() / 2, image:getHeight() / 2)

      g.setBlendMode('additive')
      g.setColor(255, 255, 255, 50 * factor)
      g.draw(image, x + 2 * factor, y + 2 * factor, 0, xscale, yscale, image:getWidth() / 2, image:getHeight() / 2)
      g.setBlendMode('alpha')
    end
  end
end

function MenuMap:keypressed(key)
  if key == 'z' then self:toggle()
  elseif key == 'escape' and self.focused then
    self:toggle()
    return true
  end
end

function MenuMap:mousereleased(mx, my, b)
  if b ~= 'l' then return end

  local u, v = ctx.u, ctx.v

  for k, v in ipairs(config.biomeOrder) do
    if math.insideCircle(mx, my, unpack(self.geometry[v])) then
      ctx.campaign:setBiome(v)
      self:toggle()
      return
    end
  end

  if my < .08 * v and not self.focused then
    self:toggle()
  end
end

function MenuMap:resize()
  table.clear(self.geometry)
end

function MenuMap:toggle()
  if self.tween.clock < self.tweenDuration then return end
  if self.focused then
    self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)
  else
    self.tween = tween.new(self.tweenDuration, self, {factor = 1}, self.tweenMethod)
  end
  self.focused = not self.focused
end
