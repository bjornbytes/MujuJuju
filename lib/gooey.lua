Gooey = class()

function Gooey:init()
  self.components = {}
  self.focused = nil
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
  self.hot = nil
  self:call('mousepressed', mx, my, b)
end

function Gooey:mousereleased(mx, my, b)
  self:call('mousereleased', mx, my, b)
  self.hot = nil
end

function Gooey:resize()
  self:call('resize')
end

function Gooey:get(code)
  return self.components[code]
end

function Gooey:call(method, ...)
  if self.focused then
    if self.focused[method] then
      if self.focused[method](self.focused, ...) then return end
    end
  end

  local components = table.filter(self.components, function(c) return c.lastDraw and tick - c.lastDraw <= 1 and c ~= self.focused end)
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

function Gooey:focus(component)
  self.focused = component
end

function Gooey:unfocus()
  self.focused = nil
end
