local g = love.graphics
HudPause = class()

local function backHandler()
  ctx.paused = not ctx.paused
end

local function quitHandler()
  Context:add(Menu, {page = 'main', user = ctx.user}, ctx.options)
  Context:remove(ctx)
end

local function backGeometry()
  local u, v = ctx.hud.u, ctx.hud.v
  local w, h = u * .2, (u * .2) / 2.6
  return {u * .5 - w / 2, v * .4, w, h}
end

local function quitGeometry()
  local u, v = ctx.hud.u, ctx.hud.v
  local w, h = u * .2, (u * .2) / 2.6
  return {u * .5 - w / 2, v * .6, w, h}
end

function HudPause:init(hud)
  self.alpha = 0

  self.back = hud.gooey:add(Button, 'hud.pause.back')
  self.back.geometry = backGeometry
  self.back:on('click', backHandler)
  self.back.text = 'Back'

  self.quit = hud.gooey:add(Button, 'hud.pause.quit')
  self.quit.geometry = quitGeometry
  self.quit:on('click', quitHandler)
  self.quit.text = 'Quit'

  local function getMousePosition = function()
    return ctx.view:frameMouseX(), ctx.view:frameMouseY()
  end

  self.back.getMousePosition, self.quit.getMousePosition = getMousePosition, getMousePosition
end

function HudPause:update()
	self.alpha = math.lerp(self.alpha, ctx.paused and 1 or 0, 8 * ls.tickrate)
end

function HudPause:draw()
  if ctx.ded or self.alpha < .01 then return end

  local u, v = ctx.hud.u, ctx.hud.v

  g.setColor(0, 0, 0, 128 * self.alpha)
  g.rectangle('fill', 0, 0, u, v)

  if self.alpha > .9 then
    self.back:draw()
    self.quit:draw()
  end
end

