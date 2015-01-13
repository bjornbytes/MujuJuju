local Infusion = extend(Spell)

local g = love.graphics

function Infusion:activate()
  local unit, ability = self:getUnit(), self:getAbility()
  self.x = unit.x
  self.y = unit.y
  self.team = unit.team

  self.timer = ability.duration

  ctx.event:emit('view.register', {object = self})
end

function Infusion:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Infusion:update()
  local unit, ability = self:getUnit(), self:getAbility()

  if not unit then ctx.spells:remove(self) end

  self.timer = timer.rot(self.timer, function()
    ctx.spells:remove(self)
  end)

  table.each(ctx.target:inRange(self, ability.range, 'ally', 'unit'), function(ally)
    ally:heal(ally.maxHealth * ability.maxHealthHeal / ability.duration * tickRate, unit)

    if ability:hasUpgrade('distortion') then
      ally.buffs:add('distortionhaste', {timer = tickRate, haste = ability.upgrades.distortion.haste})
    end

    if ability:hasUpgrade('resilience') then
      ally.buffs:add('resilience', {timer = tickRate})
    end
  end)

  if ability:hasUpgrade('distortion') then
    table.each(ctx.target:inRange(self, ability.range, 'enemy', 'unit'), function(enemy)
      enemy.buffs:add('distortionslow', {timer = tickRate, slow = ability.upgrades.distortion.slow})
    end)
  end
end

function Infusion:draw()
  local ability = self:getAbility()
  g.setColor(self:getUnit().team == ctx.player.team and {0, 255, 0} or {255, 0 , 0})
  g.circle('line', self.x, self.y, ability.range)
end

return Infusion
