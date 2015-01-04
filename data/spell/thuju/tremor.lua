local Tremor = extend(Spell)
Tremor.code = 'tremor'

local g = love.graphics

Tremor.maxHealth = 1

function Tremor:activate()
  local ability, unit = self:getAbility(), self:getUnit()

  self.timer = self.maxHealth
  self.direction = self:getAbility():getUnitDirection()

  self.x = unit.x + (unit.width / 2 + self.width / 2) * self.direction
  self.team = unit.team

  table.each(ctx.target:inRange(self, self.width / 2, 'enemy', 'unit'), function(target)
    target:hurt(self.damage, unit)
    target.buffs:add('tremorstun', {stun = self.stun, timer = self.stun})
  end)

  self.x = unit.x

  ctx.event:emit('view.register', {object = self})
end

function Tremor:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Tremor:update()
  self.timer = timer.rot(self.timer, function()
    ctx.spells:remove(self)
  end)
end

function Tremor:draw()
  local unit = self:getUnit()

  local alpha = self.timer / self.maxHealth * 255
  g.setColor(unit.team == ctx.players:get(ctx.id).team and {0, 255, 0, alpha} or {255, 0, 0, alpha})

  local x
  if self.direction == 1 then
    x = self.x + unit.width / 2
  else
    x = self.x - unit.width / 2 - self.width
  end

  local height = 64
  local y = ctx.map.height - ctx.map.groundHeight - height

  g.rectangle('line', x, y, self.width, height)
end

return Tremor
