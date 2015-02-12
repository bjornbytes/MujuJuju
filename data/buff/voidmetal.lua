local VoidMetal = extend(Buff)
VoidMetal.tags = {'armor'}

function VoidMetal:update()
  local level = self.unit:upgradeLevel('voidmetal')
  local hasBastion = self.unit:upgradeLevel('temperedbastion') > 0
  if ctx.player.dead or hasBastion then
    self.armor = .1 + level * .15
  else
    self.armor = 0
  end
end

return VoidMetal
