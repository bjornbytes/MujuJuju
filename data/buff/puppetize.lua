local Puppetize = extend(Buff)
Puppetize.tags = {}

function Puppetize:activate()
  self.unit.channeling, self.unit.spawning, self.unit.casting = false, false, false
  self.unit.team = self.unit.team == 0 and ctx.player.team or 0
  self.unit.target = nil
  self.unit.animation:set('idle', {force = true})
end

function Puppetize:deactivate()
  self.unit.team = self.unit.team == 0 and ctx.player.team or 0
  self.unit.target = nil
  self.unit.animation:set('idle', {force = true})
  if self.owner then
    self.owner.channeling = false
    self.owner.animation:set('idle', {force = true})
  end
end

return Puppetize
