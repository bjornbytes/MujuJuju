local Frostbite = extend(Spell)

local g = love.graphics

function Frostbite:activate()
  local ability, unit = self:getAbility(), self:getUnit()
  local level = unit:upgradeLevel('frostbite')

  self.timer = 2 + level
  self.dps = 4 + 2 * level
  self.y = ctx.map.height - ctx.map.groundHeight
  self.team = unit.team
  self.tundra = unit:upgradeLevel('tundra') > 0
  self.width = 125 * (self.tundra and 1.5 or 1)
  self.threshold = self.timer - 1
  self.damages = {}

  self.dead = false
  self.alpha = 1
  self.prevAlpha = self.alpha

  ctx.event:emit('view.register', {object = self})
end

function Frostbite:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Frostbite:update()
  local ability, unit = self:getAbility(), self:getUnit()

  if self.dead then
    self.prevAlpha = self.alpha
    self.alpha = self.alpha - ls.tickrate
    if self.alpha <= 0 then ctx.spells:remove(self) end
    return
  end

  self.timer = self.timer - ls.tickrate
  if self.timer < self.threshold then
    local touched = {}
    local targets = ctx.target:inRange(self, self.width / 2, 'enemy', 'unit')
    table.each(targets, function(target)
      self.damages[target.viewId] = (self.damages[target.viewId] or 0) + self.dps
      touched[target.viewId] = true
      target:hurt(self.damages[target.viewId], unit, {'spell'})
      if unit:upgradeLevel('brainfreeze') > 0 then
        target.buffs:add('brainfreeze', {timer = 1})
      end

      local wintersblight = unit:upgradeLevel('wintersblight')
      if wintersblight > 0 then
        target:hurt(target.health * (.08 * wintersblight), unit, {'spell'})
      end
    end)

    for k, v in pairs(self.damages) do
      if not touched[k] then
        self.damages[k] = nil
      end
    end

    if self.threshold > 0 then self.threshold = self.threshold - 1
    else self.dead = true end
  end
end

function Frostbite:draw()
  local image = data.media.graphics.spell.frostbite
  local scale = self.width / image:getWidth()
  g.setColor(255, 255, 255, math.lerp(self.prevAlpha, self.alpha, ls.accum / ls.tickrate) * 255)
  g.draw(image, self.x, self.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() - 20)
end

return Frostbite
