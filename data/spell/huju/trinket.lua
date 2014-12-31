local Trinket = extend(Spell)
Trinket.code = 'trinket'

local g = love.graphics

function Trinket:activate()
  local ability = self:getAbility()
  self.timer = ability.duration

  self.target.buffs:add('trinket', {
    timer = self.duration,
    frenzy = ability.frenzy,
    haste = ability.haste
  })
end

function Trinket:update()
  self.timer = timer.rot(self.timer, function()
    local ability = self:getAbility()

    if ability:hasUpgrade('imbue') then
      self.target:heal(ability.upgrades.imbue.heal, self:getUnit())
      table.each(self.target.abilities, function(ability)
        if ability.cooldown and ability.timer then
          ability.timer = math.max(ability.timer - self:getAbility().upgrades.imbue.cooldownReduction, 0)
        end
      end)
    elseif ability:hasUpgrade('surge') then
      table.each(ctx.target:inRange(self.target, ability.upgrades.surge.range, 'enemy', 'unit'), function(target)
        target:hurt(ability.upgrades.surge.damage, self:getUnit())
        local sign = math.sign(target.x - self.target.x)
        target.buffs:add('trinketknockback', {offset = ability.upgrades.surge.knockback * sign})
      end)
    end

    ctx.spells:remove(self)
  end)
end

function Trinket:draw()
  g.setColor(0, 255, 0)
  g.circle('line', self.target.x, self.target.y - 100, 5)
end

return Trinket
