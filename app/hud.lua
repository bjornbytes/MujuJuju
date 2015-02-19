Hud = class()
Hud.depth = -100

local g = love.graphics

function Hud:init()
	self.tooltip = nil
	self.tooltipRaw = ''
	self.pauseAlpha = 0
	self.pauseScreen = data.media.graphics.pauseMenu

  self.u, self.v = ctx.view.frame.width, ctx.view.frame.height
  self.health = HudHealth()
  self.experience = HudExperience()
  self.upgrades = HudUpgrades()
  self.units = HudUnits()
  self.dead = HudDead()
  self.shrujuPatches = {HudShrujuPatch(), HudShrujuPatch()}
  self.shruju = HudShruju()
  self.status = HudStatus()
  self.tooltip = Tooltip()
  self.button = Button()

	love.filesystem.write('playedBefore', 'achievement unlocked.')
	ctx.view:register(self, 'gui')
end

function Hud:update()
  local p = ctx.player

  local oldTitle = self.tooltip.tooltipText and self.tooltip.tooltipText:sub(1, self.tooltip.tooltipText:find('\n'))

	self.pauseAlpha = math.lerp(self.pauseAlpha, ctx.paused and 1 or 0, 12 * ls.tickrate)

  self.tooltip:update()
  self.button:update()
  self.status:update()
  self.health:update()
  self.experience:update()
  self.upgrades:update()
  self.shruju:update()
  self.units:update()
  self.dead:update()

  table.with(self.shrujuPatches, 'update')

  local newTitle = self.tooltip.tooltipText and self.tooltip.tooltipText:sub(1, self.tooltip.tooltipText:find('\n'))
  if self.tooltip.active and oldTitle ~= newTitle then
    ctx.sound:play('menuHover', function(sound) sound:setVolume(2) end)
  end
end

function Hud:gui()
  local u, v = self.u, self.v
  local p = ctx.player

	if not ctx.ded then

    self.status:draw()
    self.health:draw()
    self.experience:draw()
    table.with(self.shrujuPatches, 'draw')
    self.shruju:draw()

		-- Pause Menu
		if self.pauseAlpha > .01 then
      local image = self.pauseScreen
      local scale = .5 * v / image:getWidth()
			g.setColor(0, 0, 0, 128 * self.pauseAlpha)
			g.rectangle('fill', 0, 0, g.getDimensions())

			g.setColor(255, 255, 255, 255 * self.pauseAlpha)
			g.draw(self.pauseScreen, u * .5, v * .5, 0, scale, scale, self.pauseScreen:getWidth() / 2, self.pauseScreen:getHeight() / 2)
		end

    self.units:draw()
  end

  self.dead:draw()
  self.tooltip:draw()
end

function Hud:keypressed(key)
  table.with(self.shrujuPatches, 'keypressed', key)
  self.upgrades:keypressed(key)
  self.dead:keypressed(key)
end

function Hud:keyreleased(key)
  table.with(self.shrujuPatches, 'keyreleased', key)
	self.upgrades:keyreleased(key)
end

function Hud:gamepadpressed(gamepad, button)
  local x, y = love.mouse.getPosition()
  if button == 'a' then
    self:mousereleased(x, y, 'l')
  end
end

function Hud:mousepressed(x, y, b)
  table.with(self.shrujuPatches, 'mousepressed', x, y, b)
end

function Hud:mousereleased(x, y, b)
  local p = ctx.player
  if self.upgrades.active then
    self.units:mousereleased(x, y, b)
  end

  self.dead:mousereleased(x, y, b)

	if b == 'l' and ctx.paused then
    local u, v = ctx.hud.u, ctx.hud.v
		if math.inside(x, y, u * .4, v * .4, u * .19375, v * .1) then
			ctx.paused = not ctx.paused
		elseif math.inside(x, y, u * .4, v * .51, u * .19375, v * .1) then
			Context:add(Menu, nil, ctx.options)
			Context:remove(ctx)
		end
	end
end

function Hud:mousemoved(...)
  self.tooltip:dirty()
  self.status:mousemoved(...)
  self.units:mousemoved(...)
  table.with(self.shrujuPatches, 'mousemoved', ...)
  self.shruju:mousemoved(...)
end

function Hud:textinput(char)
  self.dead:textinput(char)
end

function Hud:resize()
  self.u, self.v = ctx.view.frame.width, ctx.view.frame.height
  self.tooltip:resize()
end

function Hud:menuActive()
  local active = false
  for _, patch in pairs(self.shrujuPatches) do if patch.active then active = true break end end
  active = active or self.upgrades.active
  return active
end
