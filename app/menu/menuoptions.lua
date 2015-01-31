local tween = require('lib/deps/tween/tween')
local g = love.graphics

MenuOptions = class()

function MenuOptions:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.controlGroups = {'graphics', 'sound', 'gameplay'}

  self.controls = {
    graphics = {'resolution', 'fullscreen', 'monitor', 'vsync', 'antialiasing', 'textureSmoothing', 'postprocessing', 'particles'},
    sound = {'mute', 'master', 'music', 'sound'},
    gameplay = {'colorblind'}
  }

  self.controlTypes = {
    resolution = Dropdown,
    fullscreen = Checkbox,
    monitor = Dropdown,
    vsync = Checkbox,
    antialiasing = Checkbox,
    textureSmoothing = Checkbox,
    postprocessing = Checkbox,
    particles = Checkbox,
    mute = Checkbox,
    master = Slider,
    music = Slider,
    sound = Slider,
    colorblind = Checkbox
  }

  self.geometryFunctions = {
    options = function()
      local res = {labels = {}, controls = {}}
      local u, v = ctx.u, ctx.v
      local width = self.width * u
      local x = u + self.offset
      local y = .1 * v
      local headerFont = g.setFont('mesmerize', .03 * v)
      local padding = v * .055
      for i = 1, #self.controlGroups do
        local group = self.controlGroups[i]
        local str = group:capitalize()
        table.insert(res.labels, {str, x + width - padding - headerFont:getWidth(str), y})
        y = y + v * .06

        for j = 1, #self.controls[group] do
          local control = self.controls[group][j]
          local radius = .014 * v
          if self.controlTypes[control] == Checkbox then
            res.controls[control] = {x + padding, y, radius}
          elseif self.controlTypes[control] == Dropdown then
            res.controls[control] = {x + padding - radius - 2, y - v * .02, u * .15, v * .04}
          elseif self.controlTypes[control] == Slider then
            res.controls[control] = {x + padding, y, u * .15, radius}
          end
          y = y + v * .06
        end
      end

      res.height = math.max(y, v)

      return res
    end
  }

  self.components = {}
  table.each(self.controlGroups, function(group)
    table.each(self.controls[group], function(control)
      local component = ctx.gooey:add(self.controlTypes[control] or Checkbox, control)
      component.geometry = function() return self.geometry.options.controls[control] end
      if self.controlTypes[control] == Dropdown then
        component.choices = {'choice 1', 'choice 2', 'choice 3', 'choice 4', 'choice 5', 'choice 6', 'choice 7', 'choice 8', 'choice 9'}
        component.value = 'choice 1'
      end
      component.label = control:capitalize()
      --[[component.value = ctx.options[control]
      component:on('change', function()
        ctx.options[control] = component.value
      end)]]
      self.components[control] = component
    end)
  end)

  self.active = false
  self.offset = 0
  self.tweenDuration = .25
  self.width = .35
  self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'outBack')
  self.targetScroll = 0
  self.scroll = self.targetScroll
  self.height = 10000
  self.canvas = g.newCanvas((self.width + .05) * ctx.u, ctx.v)
end

function MenuOptions:update()
  local u, v = ctx.u, ctx.v
  if self.targetScroll < 0 then self.targetScroll = math.lerp(self.targetScroll, 0, math.min(16 * tickRate, 1))
  elseif self.targetScroll > self.height - v then self.targetScroll = math.lerp(self.targetScroll, self.height - v, math.min(16 * tickRate, 1)) end
end

function MenuOptions:draw()
  self.offsetTween:update(delta)

  local u, v = ctx.u, ctx.v

  if self.offset > -1 then return end
  if self.offsetTween.clock < self.tweenDuration then
    table.clear(self.geometry)
    self.height = self.geometry.options.height
  end
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * delta)

  local x1 = u + self.offset
  local width = self.width * u

  self.canvas:clear(0, 0, 0, 0)
  ctx.workingCanvas:clear(0, 0, 0, 0)
  g.setColor(255, 255, 255)
  g.setCanvas(self.canvas)
  g.draw(ctx.screenCanvas, -u - self.offset, 0)
  g.setCanvas()

  if self.offset / -width > .1 then
    for i = 1, 4 do
      local shader = data.media.shaders.horizontalBlur
      shader:send('amount', .002 * (self.offset / -width))
      g.setShader(shader)
      ctx.workingCanvas:renderTo(function()
        g.draw(self.canvas)
      end)

      shader = data.media.shaders.verticalBlur
      shader:send('amount', .002 * (self.offset / -width))
      g.setShader(shader)
      self.canvas:renderTo(function()
        g.draw(ctx.workingCanvas)
      end)
    end
    g.setShader()
  end

  g.draw(self.canvas, x1, 0)

  g.setColor(0, 0, 0, 180)
  g.rectangle('fill', x1, 0, width + .05 * u, v)

  g.push()
  g.translate(0, -self.scroll)

  g.setColor(200, 200, 200)
  g.setFont('mesmerize', .04 * v)
  g.printCenter('Options', x1 + width / 2, .05 * v)

  g.setFont('mesmerize', .03 * v)
  g.setColor(255, 255, 255, 180)
  for i = 1, #self.geometry.options.labels do
    g.print(unpack(self.geometry.options.labels[i]))
  end

  local focused = nil
  table.each(self.components, function(component)
    if not focused and ctx.gooey.focused == component then
      focused = component
    else
      component:draw()
    end
  end)

  if focused then
    focused:draw()
  end

  g.pop()
end

function MenuOptions:keypressed(key)
  if key == ' ' then
    self:toggle()
  end
end

function MenuOptions:mousepressed(mx, my, b)
  local u, v = ctx.u, ctx.v
  local x1 = u + self.offset
  local width = self.width * u
  if math.inside(mx, my, x1, 0, width, v) then
    local scrollSpeed = .1
    if b == 'wu' then
      self.targetScroll = self.targetScroll + (v * scrollSpeed)
    elseif b == 'wd' then
      self.targetScroll = self.targetScroll - (v * scrollSpeed)
    end
  end
end

function MenuOptions:toggle()
  if self.offsetTween.clock < self.tweenDuration then return end
  if self.active then
    self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'inBack')
  else
    self.offsetTween = tween.new(self.tweenDuration, self, {offset = -self.width * ctx.u}, 'outBack')
  end
  self.active = not self.active
end
