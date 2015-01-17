local g = love.graphics
HudPortrait = class()

function HudPortrait:init()
  self.focus = 1
end

function HudPortrait:update()
  local p = ctx.player
  if not p.deck[self.focus].instance or not p.deck[self.focus].selected then
    self:refreshFocus()
  end
end

function HudPortrait:draw()
  local u, v = ctx.hud.u, ctx.hud.v
  local p = ctx.player

  g.setFont('pixel', 8)
  g.setColor(255, 255, 255)

  local entry = p.deck[self.focus]
  if entry.instance and entry.selected then
    g.print(entry.code:capitalize(), .01 * v, .01 * v)
  end
end

function HudPortrait:keypressed(key)
  if key == 'f' then
    local p = ctx.player
    self.focus = self.focus + 1
    if self.focus > #p.deck then
      self.focus = 1
    end
    self:refreshFocus()
  end
end

function HudPortrait:refreshFocus()
  local p = ctx.player

  -- Find something that is summoned and selected so we can focus on it
  for i = 1, #p.deck do
    if not p.deck[self.focus].selected or not p.deck[self.focus].instance then
      self.focus = self.focus + 1
      if self.focus > #p.deck then self.focus = 1 end
    else
      break
    end
  end
end
