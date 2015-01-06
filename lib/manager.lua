Manager = class()

function Manager:init(manages)
  self.objects = {}
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
  f.exe(object.activate, object)
  self.objects[object] = object

  return object
end

function Manager:remove(object)
  if not object then return end
  f.exe(object.deactivate, object)
  self.objects[object] = nil
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
