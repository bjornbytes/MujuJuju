local g = love.graphics
Particles = extend(Manager)

Particles.depth = -60

function Particles:init()
  self.systems = {}
  self.modes = {draw = {}, gui = {}}

  for i = 1, #data.particle do
    local particle = data.particle[i]
    local system = g.newParticleSystem(particle.image, particle.max or 1024)
    system:setOffset(particle.image:getWidth() / 2, particle.image:getHeight() / 2)
    self.systems[particle.code] = system
    self.modes[particle.mode or 'draw'][particle.code] = system
    for option, value in pairs(particle.options) do
      self:apply(particle.code, option, value)
    end
  end

  ctx.event:emit('view.register', {object = self})
  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Particles:update()
  table.with(self.systems, 'update', tickRate)
end

function Particles:draw()
  g.setColor(255, 255, 255)
  table.each(self.modes.draw, function(system, code)
    g.setBlendMode(data.particle[code].blendMode or 'alpha')
    g.draw(system)
    g.setBlendMode('alpha')
  end)
end

function Particles:gui()
  g.setColor(255, 255, 255)
  table.each(self.modes.gui, function(system, code)
    g.setBlendMode(data.particle[code].blendMode or 'alpha')
    g.draw(system)
    g.setBlendMode('alpha')
  end)
end

function Particles:emit(code, x, y, count, options)
  if not data.particle[code] then return end

  if type(count) == 'table' then
    options = count
    count = 1
  end

  options = options or {}

  table.each(options, function(value, option)
    self:apply(code, option, value)
  end)

  self.systems[code]:setPosition(x, y)
  self.systems[code]:emit(count)

  table.each(options, function(value, option)
    self:apply(code, option, data.particle[code].options[option])
  end)
end

function Particles:apply(code, option, value)
  local system = self.systems[code]
  local setter = system['set' .. option:capitalize()]
  if type(value) == 'table' then setter(system, unpack(value))
  else setter(system, value) end
end
