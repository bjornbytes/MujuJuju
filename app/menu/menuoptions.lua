local tween = require('lib/deps/tween/tween')
local g = love.graphics

MenuOptions = class()

function MenuOptions:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

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
        y = y + v * .08

        for j = 1, #self.controls[group] do
          local control = self.controls[group][j]
          local radius = .014 * v
          if self.controlTypes[control] == Checkbox then
            res.controls[control] = {x + padding, y, radius}
          elseif self.controlTypes[control] == Dropdown then
            res.controls[control] = {x + padding - radius - 2, y - v * .02, u * .22, v * .04}
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

  self.controlGroups = {'graphics', 'sound', 'gameplay'}

  self.controls = {
    graphics = {'resolution', 'fullscreen', 'display', 'vsync', 'fsaa', 'textureSmoothing', 'postprocessing', 'particles'},
    sound = {'mute', 'master', 'music', 'sound'},
    gameplay = {'colorblind'}
  }

  self.controlTypes = {
    resolution = Dropdown,
    fullscreen = Checkbox,
    display = Dropdown,
    vsync = Checkbox,
    fsaa = Checkbox,
    textureSmoothing = Checkbox,
    postprocessing = Checkbox,
    particles = Checkbox,
    mute = Checkbox,
    master = Slider,
    music = Slider,
    sound = Slider,
    colorblind = Checkbox
  }

  self.controlLabels = {
    display = 'Monitor',
    fsaa = 'Antialiasing',
    textureSmoothing = 'Texture Smoothing',
    colorblind = 'Colorblind Mode'
  }

  self.sliderData = {
    master = {0.0, 1.0, 0.05},
    music = {0.0, 1.0, 0.05},
    sound = {0.0, 1.0, 0.05}
  }

  -- Generate dropdown choices
  self.dropdownChoices = {
    resolution = {},
    display = {}
  }

  self:setMode()

  local resolutions = love.window.getFullscreenModes()
  table.sort(resolutions, function(a, b) return a.width * a.height > b.width * b.height end)
  for i = 1, #resolutions do
    self.dropdownChoices.resolution[i] = resolutions[i].width .. ' x ' .. resolutions[i].height
  end

  for i = 1, love.window.getDisplayCount() do
    table.insert(self.dropdownChoices.display, i)
  end

  -- Called at load and when an option is changed externally so components can refresh their state.
  self.refreshControls = function()
    local translators = {
      resolution = function(t)
        if t then return t[1] .. ' x ' .. t[2] end
        return self.dropdownChoices.resolution[1]
      end,
      fsaa = function(x) return x > 0 end
    }

    table.each(self.controlGroups, function(group)
      table.each(self.controls[group], function(control)
        local val = ctx.options[control]
        self.components[control].value = translators[control] and translators[control](val) or val
      end)
    end)
  end

  -- Called when a component changes its value.
  self.refreshOptions = function(keyChanged, value)
    if ctx.options[keyChanged] == value then return end

    local translators = {
      resolution = function(str)
        local w, h = str:match('(%d+)%sx%s(%d+)')
        return {w, h}
      end,
      fsaa = function(value)
        return value and 4 or 0
      end
    }

    ctx.options[keyChanged] = translators[keyChanged] and translators[keyChanged](value) or value

    if keyChanged == 'resolution' or keyChanged == 'fullscreen' or keyChanged == 'display' or keyChanged == 'vsync' or keyChanged == 'fsaa' then
      self:setMode()
    elseif keyChanged == 'mute' then
      ctx.sound:setMute(value)
    elseif keyChanged == 'master' or keyChanged == 'music' or keyChanged == 'sound' then
      ctx.sound.volumes[keyChanged] = value
      ctx.sound:refreshVolumes()
      ctx.sound:play('juju1', function(sound) sound:setPitch(.5 + value / 2) end)
    end

    saveOptions(ctx.options)
  end

  self.components = {}
  table.each(self.controlGroups, function(group)
    table.each(self.controls[group], function(control)
      local value = ctx.options[control]
      local component = ctx.gooey:add(self.controlTypes[control] or Checkbox, control, {value = value})
      component.geometry = function() return self.geometry.options.controls[control] end
      component.getOffset = function() return 0, self.scroll end
      component.label = self.controlLabels[control] or control:capitalize()
      component:on('change', function() self.refreshOptions(control, component.value) end)
      if isa(component, Dropdown) then
        component.choices = self.dropdownChoices[control]
      elseif isa(component, Slider) then
        component.min, component.max, component.round = unpack(self.sliderData[control])
      end
      self.components[control] = component
    end)
  end)

  self.refreshControls()

  self.active = false
  self.offset = 0
  self.tweenDuration = .25
  self.width = .35
  self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'outBack')
  self.targetScroll = 0
  self.prevTargetScroll = self.targetScroll
  self.scroll = self.targetScroll
  self.height = 10000
  self.canvas = g.newCanvas((self.width + .05) * ctx.u, ctx.v)
end

function MenuOptions:update()
  local u, v = ctx.u, ctx.v
  self.prevScroll = self.scroll
  local joysticks = love.joystick.getJoysticks()
  if #joysticks == 0 then
    if self.targetScroll < 0 then self.targetScroll = math.lerp(self.targetScroll, 0, math.min(12 * tickRate, 1))
    elseif self.targetScroll > self.height - v then self.targetScroll = math.lerp(self.targetScroll, self.height - v, math.min(12 * tickRate, 1)) end
  else
    if self.targetScroll < 0 then self.targetScroll = 0
    elseif self.targetScroll > self.height -v then self.targetScroll = self.height - v end
  end
end

function MenuOptions:draw()
  self.offsetTween:update(delta)

  local u, v = ctx.u, ctx.v

  if self.offset > -1 then return end
  if self.offsetTween.clock < self.tweenDuration or self.offset < self.width * u then
    table.clear(self.geometry)
    self.height = self.geometry.options.height
  end
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * delta)
  local scroll = self.scroll

  local x1 = u + self.offset
  local width = self.width * u

  self.canvas:clear(0, 0, 0, 0)
  ctx.workingCanvas:clear(0, 0, 0, 0)
  g.setColor(255, 255, 255)
  g.setCanvas(self.canvas)
  g.draw(ctx.screenCanvas, -u - self.offset, 0)
  g.setCanvas()

  if self.offset / -width > .1 then
    for i = 1, 6 do
      local shader = data.media.shaders.horizontalBlur
      shader:send('amount', 2 / self.canvas:getWidth() * (self.offset / -width))
      g.setShader(shader)
      ctx.workingCanvas:renderTo(function()
        g.draw(self.canvas)
      end)

      shader = data.media.shaders.verticalBlur
      shader:send('amount', 2 / self.canvas:getHeight() * (self.offset / -width))
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

  g.setColor(255, 255, 255, 40)
  local percent = self.scroll / ((self.height == v) and 1 or (self.height - v))
  local height = v / self.height * (v - 4)
  local scrolly = 0 + (percent * (v - height))
  local clamped = math.clamp(scrolly, 4, v - height - 4)
  local dif = math.abs(scrolly - clamped)
  if clamped > scrolly then
    height = height - dif
  elseif clamped < scrolly then
    clamped = clamped + dif
    height = height - dif
  end

  g.rectangle('fill', x1 + width - u * .005 - 1, clamped, u * .005, height)

  g.push()
  g.translate(0, -scroll)

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
    if b == 'wd' then
      self:scrollPane(1)
    elseif b == 'wu' then
      self:scrollPane(-1)
    end
  end
end

function MenuOptions:gamepadpressed(gamepad, button)
  if button == 'b' and self.active then
    self:toggle()
  end
end

function MenuOptions:gamepadaxis(gamepad, axis, value)
  if axis == 'righty' then
    self:scrollPane(value)
  end
end

function MenuOptions:scrollPane(direction)
  local scrollSpeed = .05
  self.targetScroll = self.targetScroll + (ctx.v * scrollSpeed) * direction
end

function MenuOptions:resize()
  self.canvas = g.newCanvas((self.width + .05) * ctx.u, ctx.v)
  if self.active then self.offsetTween = tween.new(self.tweenDuration, self, {offset = -self.width * ctx.u}, 'inBack')
  else self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'outBack') end
  table.clear(self.geometry)
end

function MenuOptions:toggle(force)
  if self.offsetTween.clock < self.tweenDuration then return end
  if self.active then
    self.offsetTween = tween.new(self.tweenDuration, self, {offset = 0}, 'inBack')
  else
    self.offsetTween = tween.new(self.tweenDuration, self, {offset = -self.width * ctx.u}, 'outBack')
  end
  self.active = not self.active
end

function MenuOptions:setMode()
  local options = table.only(ctx.options, {'fullscreen', 'display', 'vsync', 'fsaa'})

  ctx.options.resolution = ctx.options.resolution or {0, 0}
  local borderless = table.eq(ctx.options.resolution, {0, 0}) or (love.window and table.eq(ctx.options.resolution, {love.window.getDesktopDimensions()}))
  options.fullscreentype = borderless and 'desktop' or 'normal'

  if love.window.setMode(ctx.options.resolution[1], ctx.options.resolution[2], options) then
    love.window.setTitle('Muju Juju')
    love.window.setIcon(love.image.newImageData('media/graphics/icon.png'))
    ctx:resize()
  else
    print('There was a problem applying the requested window options... PANIC _>_>_>')
  end
end
