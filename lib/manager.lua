Manager = class()

function Manager:init(manages)
  self.objects = {}
  self.nextId = 1
  self.manages = self.manages or manages
end

function Manager:update()
  table.with(self.objects, 'update')
end

function Manager:paused()
  table.with(self.objects, 'paused')
end

function Manager:add(kind, vars)
  if type(kind) == 'string' then kind = data[self.manages][kind] end
  local object = kind()
  table.merge(vars, object, true)
  object.id = self.nextId
  self.nextId = self.nextId + 1
  if self.nextId >= 1024 then
    if self.objects[1] then print('uh oh we have too many ' .. self.manages) end
    self.nextId = 1
  end
  f.exe(object.activate, object)
  self.objects[object.id] = object

  return object
end

function Manager:remove(object)
  if type(object) == 'number' then object = self.objects[object] end
  if not object then return end
  f.exe(object.deactivate, object)
  self.objects[object.id] = nil
end

function Manager:get(id)
  return self.objects[id]
end

function Manager:each(fn)
  table.each(self.objects, fn)
end

function Manager:filter(fn)
  return table.filter(self.objects, fn)
end

function Manager:count()
  if not next(self.objects) then return 0 end
  return table.count(self.objects)
end
