local g = love.graphics
HudPortrait = class()

local hotkeys = {'q', 'w', 'e', 'r'}

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
    local str = entry.code:capitalize()
    local unit = data.unit[p.deck[self.focus].code]
    if unit.castables then
      for i, ability in ipairs(unit.castables) do
        if p.deck[self.focus].instance:hasAbility(ability) then
          str = str .. '\n' .. hotkeys[i]:capitalize() .. ': ' .. ability:capitalize()
        end
      end
    end
    g.print(str, .01 * v, .01 * v)
  end
end

function HudPortrait:keypressed(key)
  local p = ctx.player
  if key == 'f' then
    self.focus = self.focus + 1
    if self.focus > #p.deck then
      self.focus = 1
    end
    self:refreshFocus()
  else
    local entry = p.deck[self.focus]
    if entry.instance and entry.selected then
      for i = 1, #hotkeys do
        if key == hotkeys[i] then
          local code = data.unit[entry.code].castables[i]
          local instance = entry.instance
          if instance then
            local index, ability = instance:hasAbility(code)
            if ability and ability:canUse() then
              ability:use()
            end
          end
        end
      end
    end
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
