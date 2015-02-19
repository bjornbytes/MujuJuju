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
      local width = math.lerp(.4 * v, .6 * u, factor)
      local height = width * (10 / 16)
      local x = math.lerp(u * .8, u * .5, math.clamp(factor ^ 2, 0, 1))
      local y = math.lerp(.35 * v, v * .5, math.clamp(factor ^ .5, 0, 1))
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
      return {x + .204 * w, y + .225 * h}
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
  self.factor = 0
  self.tweenDuration = .6
  self.tweenMethod = 'outQuint'
  self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)
  self.alpha = 0
  self.prevAlpha = self.alpha
  self.scales = {}
  self.prevScales = {}
end

function MenuMap:update()
  local mx, my = love.mouse.getPosition()

  self.prevAlpha = self.alpha
  self.alpha = math.lerp(self.alpha, self.active and 1 or 0, math.min(6 * ls.tickrate, 1))

  for k, v in ipairs(config.biomeOrder) do
    local hover = math.insideCircle(mx, my, unpack(self.geometry[v]))
    self.prevScales[v] = self.scales[v] or 1
    self.scales[v] = math.lerp(self.scales[v] or 1, (hover or ctx.main.selectedBiome == k) and 1.15 or .9, math.min(16 * ls.tickrate, 1))
  end
end

function MenuMap:draw()
  self.tween:update(ls.dt)

  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  if self.tween.clock < self.tweenDuration then
    table.clear(self.geometry)
  end

  local alpha = math.lerp(self.prevAlpha, self.alpha, ls.accum / ls.tickrate)

  -- Fade out background
  g.setColor(0, 0, 0, 100 * alpha)
  g.rectangle('fill', 0, 0, u, v)

  local x, y, w, h = unpack(self.geometry.frame)
  local image = data.media.graphics.worldmap.background
  local xscale = w / image:getWidth()
  local yscale = h / image:getHeight()
  g.setColor(255, 255, 255)
  g.draw(image, x, y, 0, xscale, yscale)

  if not self.active and math.inside(mx, my, x, y, w, h) and not ctx.optionsPane.active then
    g.setColor(255, 255, 255, 20)
    g.setBlendMode('additive')
    g.draw(image, x, y, 0, xscale, yscale)
    g.setBlendMode('alpha')
  end

  for k, v in ipairs(config.biomeOrder) do
    local has = table.has(ctx.user.biomes, v)
    if k >= 2 then
      local x, y = unpack(self.geometry['trail' .. (k - 1)])
      local image = data.media.graphics.worldmap['trail' .. (k - 1)]
      g.setColor(has and {255, 255, 255} or {255, 255, 255, 100})
      g.draw(image, x, y, 0, xscale, yscale, image:getWidth() / 2, image:getHeight() / 2)
    end

    local x, y, r = unpack(self.geometry[v])
    local image = data.media.graphics.worldmap.circle
    local scale = r * 2 / image:getWidth()
    scale = scale * math.lerp(self.prevScales[v], self.scales[v], ls.accum / ls.tickrate)
    if ctx.main.selectedBiome == k then g.setColor(255, 255, 255)
    else g.setColor(255, 255, 255, 100) end
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)

    if self.active then
      local image = data.media.graphics.worldmap[v]
      local x, y = unpack(self.geometry[v .. 'Title'])
      g.draw(image, x, y, 0, xscale, yscale, image:getWidth() / 2, image:getHeight() / 2)

      if not has then
        local image = data.media.graphics.menu.lock
        g.setColor(255, 255, 255, 200)
        g.draw(image, x, y, 0, xscale * .75, yscale * .75, image:getWidth() / 2, image:getHeight() / 2)
      end
    end
  end
end

function MenuMap:keypressed(key)
  if key == 'z' then self:toggle()
  elseif key == 'escape' and self.active then
    self:toggle()
    return true
  end
end

function MenuMap:mousepressed(mx, my, b)
  if b ~= 'l' then return end

  for k, v in ipairs(config.biomeOrder) do
    if math.insideCircle(mx, my, unpack(self.geometry[v])) and table.has(ctx.user.biomes, v) then
      ctx.main:setBiome(k)
      self.scales[v] = 1.5
      return
    end
  end

  if math.inside(mx, my, unpack(self.geometry.frame)) then
    if not self.active then self:toggle() end
  elseif self.active then
    self:toggle()
  end
end

function MenuMap:resize()
  table.clear(self.geometry)
end

function MenuMap:toggle()
  if self.tween.clock < self.tweenDuration then return end
  if self.active then
    self.tween = tween.new(self.tweenDuration, self, {factor = 0}, self.tweenMethod)
  else
    self.tween = tween.new(self.tweenDuration, self, {factor = 1}, self.tweenMethod)
  end
  self.active = not self.active
end
