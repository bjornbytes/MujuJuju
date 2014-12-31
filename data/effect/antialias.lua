local Antialias = {}
Antialias.code = 'antialias'

function Antialias:init()
  self:resize()
end

function Antialias:resize()
  self.shader = data.media.shaders.fxaa
  self.shader:send('stepsize', {1 / love.graphics.getWidth(), 1 / love.graphics.getHeight()})
end

return Antialias
