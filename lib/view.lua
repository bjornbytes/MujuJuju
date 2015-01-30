View = class()

local g = love.graphics

function View:init()
  self.x = 0
  self.y = 0
  self.width = 1067
  self.height = 600
  self.xmin = 0
  self.ymin = 0
  self.xmax = self.width
  self.ymax = self.height

  self.frame = {}
  self.frame.x = 0
  self.frame.y = 0
  self.frame.width = love.graphics.getWidth()
  self.frame.height = love.graphics.getHeight()

  self.vx = 0
  self.vy = 0

  self.viewId = 0
  self.draws = {}
  self.guis = {}
  self.effects = {}
  self.toRemove = {}
  self.target = nil

  self:resize()

  self.prevx = 0
  self.prevy = 0
  self.prevscale = self.scale

  self.shake = 0

  ctx.event:on('view.register', function(data)
    self:register(data.object, data.mode)
  end)

  ctx.event:on('view.unregister', function(data)
    self:unregister(data.object)
  end)
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale

  local mx = love.mouse.getX()
  if mx < self.frame.x + (.02 * self.frame.width) then
    self.vx = -1000
  elseif mx > self.frame.x + (.98 * self.frame.width) then
    self.vx = 1000
  end

  self.x = self.x + self.vx * tickRate
  self.y = self.y + self.vy * tickRate

  self:contain()

  self.shake = math.lerp(self.shake, 0, 8 * tickRate)

  while #self.toRemove > 0 do
    local x = self.toRemove[1]

    if x.draw then
      for i = 1, #self.draws do
        if self.draws[i] == x then table.remove(self.draws, i) i = #self.draws + 1 end
      end
    end

    if x.gui then
      for i = 1, #self.guis do
        if self.guis[i] == x then table.remove(self.guis, i) i = #self.guis + 1 end
      end
    end

    for i = 1, #self.effects do
      if self.effects[i] == x then table.remove(self.effects, i) i = #self.effects + 1 end
    end

    table.remove(self.toRemove, 1)
  end

  table.sort(self.draws, function(a, b)
    return a.depth == b.depth and a.viewId < b.viewId or a.depth > b.depth
  end)
end

function View:draw()
  local w, h = g.getDimensions()
  local source, target = self.sourceCanvas, self.targetCanvas

  self:worldPush()

  source:clear()
  target:clear()
  g.setCanvas(source)
  for i = 1, #self.draws do self.draws[i]:draw() end
  g.setCanvas()
  g.pop()

  for i = 1, #self.effects do
    local effect = self.effects[i]
    g.setColor(255, 255, 255)
    if effect.applyEffect then
      effect:applyEffect(source, target)
    else
      g.setShader(effect.shader)
      g.setCanvas(target)
      g.draw(source)
    end
    g.setCanvas()
    g.setShader()
    source, target = target, source
  end

  g.setColor(255, 255, 255)
  g.draw(source)

  g.push()

  local fr = self.frame
  local fx, fy, fw, fh = fr.x, fr.y, fr.width, fr.height
  g.translate(fx, fy)

  for i = 1, #self.guis do self.guis[i]:gui() end

  g.pop()

  g.setColor(0, 0, 0, 255)
  g.rectangle('fill', 0, 0, w, fy)
  g.rectangle('fill', 0, 0, fx, h)
  g.rectangle('fill', 0, fy + fh, w, h - (fy + fh))
  g.rectangle('fill', fx + fw, 0, w - (fx + fw), h)
end

function View:resize()
  local w, h = love.graphics.getDimensions()
  local ratio = w / h

  self.frame.x, self.frame.y, self.frame.width, self.frame.height = 0, 0, self.width, self.height
  if (self.width / self.height) > (w / h) then
    self.scale = w / self.width
    local margin = math.max(math.round(((h - w * (self.height / self.width)) / 2)), 0)
    self.frame.y = margin
    self.frame.height = h - 2 * margin
    self.frame.width = w
  else
    self.scale = h / self.height
    local margin = math.max(math.round(((w - h * (self.width / self.height)) / 2)), 0)
    self.frame.x = margin
    self.frame.width = w - 2 * margin
    self.frame.height = h
  end

  self.sourceCanvas = love.graphics.newCanvas(w, h)
  self.targetCanvas = love.graphics.newCanvas(w, h)
end

function View:register(x, action)
  x.viewId = self.viewId
  action = action or 'draw'
  if action == 'draw' then
    table.insert(self.draws, x)
    x.depth = x.depth or 0
  elseif action == 'gui' then
    table.insert(self.guis, x)
  elseif action == 'effect' then
    table.insert(self.effects, x)
  end

  self.viewId = self.viewId + 1
end

function View:unregister(x)
  table.insert(self.toRemove, x)
end

function View:convertZ(z)
  return (.8 * z) ^ (1 + (.0008 * z))
end

function View:three(x, y, z)
  local sx, sy = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  z = self:convertZ(z)
  return x - (z * ((sx + self.width / 2 - x) / 500)), y - (z * ((sy + self.height / 2 - y) / 500))
end

function View:threeDepth(x, y, z)
  return math.clamp(math.distance(x, y, self.x + self.width / 2, self.y + self.height / 2) * self.scale - 1000 - z, -4096, -16)
end

function View:contain()
  self.x = math.clamp(self.x, 0, self.xmax - self.width)
  self.y = math.clamp(self.y, 0, self.ymax - self.height)
end

function View:worldPoint(x, y)
  x = math.round(((x - self.frame.x) / self.scale) + self.x)
  if y then y = math.round(((y - self.frame.y) / self.scale) + self.y) end
  return x, y
end

function View:screenPoint(x, y)
  local vx, vy = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  x = (x - vx) * self.scale
  if y then y = (y - vy) * self.scale end
  return x, y
end

function View:worldMouseX()
  return math.round(((love.mouse.getX() - self.frame.x) / self.scale) + self.x)
end

function View:worldMouseY()
  return math.round(((love.mouse.getY() - self.frame.y) / self.scale) + self.y)
end

function View:frameMouseX()
  return love.mouse.getX() - self.frame.x
end

function View:frameMouseY()
  return love.mouse.getY() - self.frame.y
end

function View:screenshake(amount)
  if self.shake > amount then self.shake = self.shake + (amount / 2) end
  self.shake = amount
end

function View:worldPush()
  local x, y, s = unpack(table.interpolate({self.prevx, self.prevy, self.prevscale}, {self.x, self.y, self.scale}, tickDelta / tickRate))
  local shakex = 1 - (2 * love.math.noise(self.shake + x + tickDelta))
  local shakey = 1 - (2 * love.math.noise(self.shake + y + tickDelta))
  x = x + (shakex * self.shake)
  y = y + (shakey * self.shake)

  g.push()
  g.translate(self.frame.x, self.frame.y)
  g.scale(s)
  g.translate(-x, -y)
end

function View:guiPush()
  g.push()
  g.translate(self.frame.x, self.frame.y)
end
