local g = love.graphics

local function lerpAnimation(code, key, val)
  ctx.prevAnimationTransforms[code][key] = ctx.animationTransforms[code][key]
  ctx.animationTransforms[code][key] = lume.lerp(ctx.animationTransforms[code][key] or val, val, math.min(10 * ls.tickrate, 1))
end

MenuChoose = class()

function MenuChoose:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    colors = function()
      local u, v = ctx.u, ctx.v
      local ct = #config.player.colorOrder
      local width = .08 * v * 1.3
      local inc = width + .02 * v
      local x = u * .5 - (inc * (ct - 1) / 2)
      local res = {}
      for name, color in pairs(config.player.colors) do
        table.insert(res, {x - width / 2, v * .55, width, .08 * v})
        x = x + inc
      end
      return res
    end,

    back = function()
      local u, v = ctx.u, ctx.v
      return {u * .125, v * .715, u * .2, v  * .1}
    end,

    next = function()
      local u, v = ctx.u, ctx.v
      return {u * .675, v * .715, u * .2, v  * .1}
    end
  }

  self.active = false

  -- Initialize user
  self.user = table.copy(config.defaultUser)

  self.back = ctx.gooey:add(Button, 'menu.choose.back')
  self.back.geometry = function() return self.geometry.back end
  self.back:on('click', function() ctx:setPage('select', self.destination) end)
  self.back.text = 'Back'

  self.next = ctx.gooey:add(Button, 'menu.choose.next')
  self.next.geometry = function() return self.geometry.next end
  self.next:on('click', function() self:finished() end)
  self.next.text = 'Ready!'
end

function MenuChoose:activate(destination)
  self.destination = destination
end

function MenuChoose:update()
  self.active = ctx.page == 'choose'

  --[[if self.active then
    local mx, my = love.mouse.getPosition()
    local minions = self.geometry.minions
    for i = 1, #minions do
      local code = config.starters[i]
      if i == self.selectedMinion then
        lerpAnimation(code, 'scale', 1.25)
      else
        lerpAnimation(code, 'scale', .9)
      end
    end
  end]]
end

function MenuChoose:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v
  g.setFont('mesmerize', .04 * v)

  g.setColor(0, 0, 0, 100)
  g.rectangle('fill', u * .125, v * .23, u * .75, v * .46)

  if #self.user.name == 0 then g.setColor(255, 0, 0)
  else g.setColor(255, 255, 255) end
  g.printShadow('Enter your name', u * .5, v * .31, true)

  g.setFont('mesmerize', .06 * v)
  g.setColor(255, 255, 255)
  g.printShadow(self.user.name, u * .5, v * .38, true)

  local fontHeight = g.getFont():getHeight()
  local lineX = u * .5 + g.getFont():getWidth(self.user.name) / 2 + 1
  g.line(lineX, v * .38 - fontHeight / 2, lineX, v * .38 + fontHeight / 2)

  g.printShadow('Pick your color', u * .5, v * .5, true)

  local colors = self.geometry.colors
  for i = 1, #colors do
    local name = config.player.colorOrder[i]
    local color = config.player.colors[name]
    g.setColor(color[1] * 255, color[2] * 255, color[3] * 255)
    g.rectangle('fill', unpack(colors[i]))
    if self.user.color == name then
      g.setColor(255, 255, 255)
      g.rectangle('line', unpack(colors[i]))
    end
  end

  g.setColor(255, 255, 255)

  ctx.animations.muju:draw(u * .2, v * .5)

  local color = self.user and self.user.color or 'purple'
  for _, slot in pairs({'robebottom', 'torso', 'front_upper_arm', 'rear_upper_arm', 'front_bracer', 'rear_bracer'}) do
    local slot = ctx.animations.muju.spine.skeleton:findSlot(slot)
    slot.r, slot.g, slot.b = unpack(config.player.colors[color])
  end

  self.back:draw()
  self.next:draw()
end

function MenuChoose:keypressed(key)
  if not self.active then return end
  if key == 'backspace' then
    self.user.name = self.user.name:sub(1, -2)
    ctx.sound:play('juju1', function(sound) sound:setPitch(.6) end)
  end
end

function MenuChoose:keyreleased(key)
  if not self.active then return end
  if key == 'escape' then
    ctx:setPage('select', self.destination)
  end
  return self.active
end

function MenuChoose:mousepressed(mx, my, b)
  if not self.active then return end
  if b == 'l' then
    local colors = self.geometry.colors
    for i = 1, #colors do
      if self.user.color ~= config.player.colorOrder[i] and math.inside(mx, my, unpack(colors[i])) then
        self.user.color = config.player.colorOrder[i]
        ctx.sound:play('juju1', function(sound) sound:setPitch(.75) end)
      end
    end
  end
end

function MenuChoose:textinput(char)
  if not self.active then return end
  if #self.user.name < 16 and char:match('%a*%d*') then
    self.user.name = self.user.name .. char
    ctx.sound:play('juju1', function(sound) sound:setPitch(.6) end)
  end
end

function MenuChoose:resize()
  table.clear(self.geometry)
end

function MenuChoose:finished()
  if #self.user.name == 0 then return end
  saveUser(self.user)
  ctx.user = self.user
  ctx:startGame({mode = 'campaign', biome = 'forest', tutorial = true, destination = self.destination})
end
