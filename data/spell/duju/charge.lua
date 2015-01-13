local Charge = extend(Spell)

function Charge:activate()
  self.unit = self:getUnit()
  self.startx = self.unit.x
  self.damaged = {}
  ctx.event:emit('view.register', {object = self})
end

function Charge:deactivate()
  ctx.event:emit('view.unregister', {object = self})
end

function Charge:update()
  local direction = self.ability:getUnitDirection() 
  local charging = math.abs(self.startx - self.unit.x) < self.ability.range

  if charging then
    self.unit.x = self.unit.x + direction * self.speed * tickRate
    table.each(ctx.target:inRange(self.unit, 1, 'enemy', 'unit'), function(target)
      if not self.damaged[target.id] then
        target:hurt(self.damage)
        self.damaged[target.id] = true 
        if self.ability:hasUpgrade('trample') then
          target.buffs:add('chargestun', {stun = self.duration, timer = self.duration})
        else
          target.buffs:add('chargeslow', {timer = self.duration, slow = self.slow})
        end
      end
    end)
  else
    ctx.spells:remove(self)
  end
end

function Charge:draw()
 -- Nothing yet
end

return Charge
