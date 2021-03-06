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
    graphics = {'resolution', 'display', 'vsync', 'msaa', 'textureSmoothing', 'postprocessing', 'particles'},
    sound = {'mute', 'master', 'music', 'sound'},
    gameplay = {'colorblind', 'powersave', 'offline'}
  }

  self.controlTypes = {
    resolution = Dropdown,
    display = Dropdown,
    vsync = Checkbox,
    msaa = Checkbox,
    textureSmoothing = Checkbox,
    postprocessing = Checkbox,
    particles = Checkbox,
    mute = Checkbox,
    master = Slider,
    music = Slider,
    sound = Slider,
    colorblind = Checkbox,
    powersave = Checkbox,
    offline = Checkbox
  }

  self.controlLabels = {
    display = 'Monitor',
    msaa = 'Antialiasing',
    textureSmoothing = 'Texture Smoothing',
    colorblind = 'Colorblind Mode',
    powersave = 'Power Saving',
    offline = 'Offline Mode'
  }

  self.controlDescriptions = {
    display = 'Which monitor Muju Juju runs on',
    postprocessing = 'Cool effects like bloom and distortions',
    textureSmoothing = 'Reduces rendering artifacts, especially on smaller screens',
    powersave = 'If you are on a laptop, this will intelligently limit the framerate so Muju Juju doesn\'t kill your battery.',
    offline = 'Muju Juju won\'t ever send or load highscores.'
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
    table.insert(self.dropdownChoices.display, love.window.getDisplayName(i))
  end

  -- Called at load and when an option is changed externally so components can refresh their state.
  self.refreshControls = function()
    local translators = {
      resolution = function(t)
        if t then return t[1] .. ' x ' .. t[2] end
        return self.dropdownChoices.resolution[1]
      end,
      display = function(index)
        return love.window.getDisplayName(index)
      end,
      msaa = function(x) return x and x > 0 or false end
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
    local translators = {
      resolution = function(str)
        local w, h = str:match('(%d+)%sx%s(%d+)')
        return {w, h}
      end,
      display = function(str)
        for i = 1, love.window.getDisplayCount() do
          if love.window.getDisplayName(i) == str then return i end
        end

        return 1
      end,
      msaa = function(value)
        return value and 4 or 0
      end
    }

    if table.eq(translators[keyChanged] and translators[keyChanged](value) or value, ctx.options[keyChanged]) then return end

    ctx.options[keyChanged] = translators[keyChanged] and translators[keyChanged](value) or value

    if keyChanged == 'resolution' or keyChanged == 'display' or keyChanged == 'vsync' or keyChanged == 'msaa' then
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
  self.tooltipFactor = 0
  self.prevTooltipFactor = self.tooltipFactor
  self.tooltipText = ''
end

function MenuOptions:update()
  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()
  self.prevScroll = self.scroll
  self.prevTooltipFactor = self.tooltipFactor

  local joysticks = love.joystick.getJoysticks()
  if #joysticks == 0 then
    if self.targetScroll < 0 then self.targetScroll = math.lerp(self.targetScroll, 0, math.min(12 * ls.tickrate, 1))
    elseif self.targetScroll > self.height - v then self.targetScroll = math.lerp(self.targetScroll, self.height - v, math.min(12 * ls.tickrate, 1)) end
  else
    if self.targetScroll < 0 then self.targetScroll = 0
    elseif self.targetScroll > self.height -v then self.targetScroll = self.height - v end
  end

  local dirty = false
  table.each(self.controlGroups, function(group)
    table.each(self.controls[group], function(control)
      local ox, oy = self.components[control]:getOffset()
      local mx, my = mx + ox, my + oy
      if self.controlDescriptions[control] and self.components[control]:contains(mx, my) and ctx.gooey.focused ~= self.components[control] and (not ctx.gooey.focused or not ctx.gooey.focused:contains(mx, my)) then
        self.tooltipFactor = math.lerp(self.tooltipFactor, 1, math.min(6 * ls.tickrate, 1))
        self.tooltipText = self.controlDescriptions[control]
        dirty = true
      end
    end)
  end)

  if not dirty then
    self.tooltipFactor = math.lerp(self.tooltipFactor, 0, math.min(1 * ls.tickrate, 1))
  end
end

function MenuOptions:draw()
  self.offsetTween:update(ls.dt)

  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  if self.offset > -1 then return end
  if self.offsetTween.clock < self.tweenDuration or self.offset < self.width * u then
    table.clear(self.geometry)
    self.height = self.geometry.options.height
  end
  self.scroll = math.lerp(self.scroll, self.targetScroll, 8 * ls.dt)
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

  if self.tooltipFactor > .01 and self.tooltipText ~= '' then
    local tooltipFactor = math.lerp(self.prevTooltipFactor, self.tooltipFactor, ls.accum / ls.tickrate)
    tooltipFactor = math.clamp((tooltipFactor - .8) / .2, 0, 1)
    local str = self.tooltipText
    local font = g.setFont('mesmerize', .02 * v)
    local width, lines = font:getWrap(str, .2 * u)
    width = width + .02 * v
    local height = (font:getHeight() * lines) + .02 * v
    local x, y = mx + 8, my + 8
    if x + width > u then x = u - width end
    if y + height > v then y = v - height end
    g.setColor(0, 0, 0, 200 * tooltipFactor)
    g.rectangle('fill', x, y, width, height)
    g.setColor(255, 255, 255, 255 * tooltipFactor)
    g.printf(str, x + .01 * v, y + .01 * v, width)
  end
end

function MenuOptions:keyreleased(key)
  if key == 'escape' and self.active then
    self:toggle()
    return true
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

    return true
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

function MenuOptions:setMode(n)
  n = n or 0
  if n and n > 1 then return end

  if Context.started and not self.active then
    ctx:resize()
    return
  end

  local resolutions = love.window.getFullscreenModes()
  local dw, dh = love.window.getDesktopDimensions()
  local options = table.only(ctx.options, {'display', 'vsync', 'msaa'})

  MenuOptions.pixelScale = love.window and love.window.getPixelScale() or 1

  options.highdpi = true

  if not ctx.options.resolution then
    ctx.options.resolution = {resolutions[1].width, resolutions[1].height}
  end

  if tonumber(ctx.options.resolution[1]) == resolutions[1].width and tonumber(ctx.options.resolution[2]) == resolutions[1].height then
    options.fullscreen = true
    options.fullscreentype = 'desktop'
  else
    options.fullscreen = false
  end

  if love.window.setMode(ctx.options.resolution[1] / MenuOptions.pixelScale, ctx.options.resolution[2] / MenuOptions.pixelScale, options) then
    love.window.setTitle('Muju Juju')
    love.window.setIcon(love.image.newImageData('media/graphics/icon.png'))
    ctx:resize()

    if love.window.getPixelScale() == 2 then
      self:setMode(n + 1)
    end
  else
    print('There was a problem applying the requested window options... PANIC _>_>_>')
  end
end
