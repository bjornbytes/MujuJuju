Event = class()

function Event:init()
  self.handlers = {}
end

function Event:on(event, fn, context)
  self.handlers[event] = self.handlers[event] or {}
  if context then
    self.handlers[event][context] = fn
  else
    table.insert(self.handlers[event], fn)
  end
end

function Event:emit(event, data)
  if not self.handlers[event] then return end
  for _, fn in pairs(self.handlers[event]) do
    fn(data)
  end
end

function Event:remove(event, context)
  if self.handlers[event] and self.handlers[event][context] then
    self.handlers[event][context] = nil
  end
end
