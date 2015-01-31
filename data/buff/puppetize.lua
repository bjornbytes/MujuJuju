local Puppetize = class()

function Puppetize:activate()
  self.team = self.team == 0 and ctx.player.team or 0
end

function Puppetize:deactivate()
  self.team = self.team == 0 and ctx.player.team or 0
end

return Puppetize
