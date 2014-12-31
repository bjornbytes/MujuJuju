local Headbutt = extend(Buff)
Headbutt.code = 'headbutt'
Headbutt.name = 'Headbutt'
Headbutt.tags = {}

function Headbutt:postattack(target, damage)
  local modifier = self.ability.damageModifier
  local structure = target.code == 'shrine'

  if structure then
    modifier = self.ability.structureDamageModifier
  else
    local offset = self.ability.knockbackDistance

    if self.ability:hasUpgrade('bash') then
      offset = self.ability.knockbackDistance + self.ability.knockbackDistance * self.ability.upgrades.bash.knockbackModifier
    end

    if target.buffs then target.buffs:add('headbuttknockback', {offset = offset, ability = self.ability}) end
  end

  local damage = self.unit.damage * modifier
  target:hurt(damage + damage * modifier, self.unit)

  self.unit.buffs:remove(self)
end

return Headbutt
