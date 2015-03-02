local VujuAttack = extend(Spell)

function VujuAttack:activate()
  ctx.particles:emit('vujuattack', self.target.x, self.target.y - self.target.height / 2, 12)
  ctx.spells:remove(self)
end

return VujuAttack
