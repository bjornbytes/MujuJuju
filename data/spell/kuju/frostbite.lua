local Frostbite = extend(Spell)

local g = love.graphics

Frostbite.width = 100

function Frostbite:activate()
  local ability, unit = self:getAbility(), self:getUnit()

  self.timer = ability.duration
  self.y = ctx.map.height - ctx.map.groundHeight
  self.team = unit.team

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
    local damage = 10 * unit:upgradeLevel('frostbite') * ls.tickrate
    if unit:upgradeLevel('coldfeet') > 0 and target.buffs and target.buffs:slowed() then damage = damage * 2 end
    target:hurt(ability.dps * ls.tickrate, unit, {'spell'})
  end)
end

function Frostbite:draw()
  local image = data.media.graphics.spell.frostbite
  local scale = self.width / image:getWidth()
  g.setColor(255, 255, 255, math.max(self.timer / .2, 1) * 255)
  g.draw(image, self.x, self.y, 0, scale, scale, image:getWidth() / 2, image:getHeight() - 20)
end

return Frostbite
