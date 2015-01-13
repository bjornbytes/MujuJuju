local Frostbite = extend(Spell)

local g = love.graphics

function Frostbite:activate()
  local ability, unit = self:getAbility(), self:getUnit()

  self.timer = ability.duration
  self.y = ctx.map.height - ctx.map.groundHeight
  self.team = unit.team

  self.targets = {}
  self.dirtyTargets = {}

  ctx.event:emit('view.register', {object = self})
end

function Frostbite:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Frostbite:update()
  local ability, unit = self:getAbility(), self:getUnit()

  self.timer = timer.rot(self.timer, function()
    ctx.spells:remove(self)
  end)

  local targets = ctx.target:inRange(self, self.width / 2, 'enemy', 'unit')
  table.each(targets, function(target)
    target.buffs:add('frostbiteslow', {timer = tickRate, slow = ability.slow})
    target:hurt(ability.dps * tickRate, unit)

    if not self.dirtyTargets[target.id] then
      self.targets[target.id] = (self.targets[target.id] or 0) + tickRate
      if self.targets[target.id] >= ability.rootThreshold then
        target.buffs:add('frostbiteroot', {timer = self.rootDuration})
        self.dirtyTargets[target.id] = true
      end
    end
  end)
end

function Frostbite:draw()
  local image = data.media.graphics.spell.frostbite
  local scale = self.width / image:getWidth()
  g.setColor(255, 255, 255)
  g.draw(image, self.x, self.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() - 20)
end

return Frostbite
