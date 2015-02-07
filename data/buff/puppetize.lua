local Puppetize = extend(Buff)
Puppetize.tags = {}

function Puppetize:activate()
  self.unit.team = self.unit.team == 0 and ctx.player.team or 0
  self.unit.target = nil
  self.unit.animation:set('idle', {force = true})
end

function Puppetize:deactivate()
  self.unit.team = self.unit.team == 0 and ctx.player.team or 0
  self.unit.target = nil
  self.unit.animation:set('idle', {force = true})
end

return Puppetize
