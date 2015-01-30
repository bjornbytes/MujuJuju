Gooey = class()

function Gooey:init()
  self.components = {}
end

function Gooey:update()
  self:call('update')
end

function Gooey:draw(component)
  if type(component) == 'string' then component = self:get(component) end
  if not component then return end
  component.lastDraw = tick
  component:render()
end

function Gooey:keypressed(key)
  self:call('keypressed', key)
end

function Gooey:keyreleased(key)
  self:call('keyreleased', key)
end

function Gooey:mousepressed(mx, my, b)
  self:call('mousepressed', mx, my, b)
end

function Gooey:mousereleased(mx, my, b)
  self:call('mousereleased', mx, my, b)
end

function Gooey:get(code)
  return self.components[code]
end

function Gooey:call(method, ...)
  local components = table.filter(self.components, function(c) return c.lastDraw and tick - c.lastDraw <= 1 end)
  return table.with(components, method, ...)
end

function Gooey:add(class, code, vars)
  local component = class()
  table.merge(vars, component, true)
  component.code = code
  component.gooey = self
  f.exe(component.activate, component)
  self.components[code] = component
  return component
end
