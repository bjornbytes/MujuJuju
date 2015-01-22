Patcher = class()

function Patcher:load()
  self.hashes = {}
  self.hasherThread = love.thread.newThread('app/thread/hasher.lua')
  self.hasherOut = love.thread.getChannel('hasher.out')
  
  self.hasherThread:start()
end

function Patcher:update()
  repeat
    local hashed = self.hasherOut:pop()
    if hashed == 'done' then
      self.hash = self.hasherOut:pop()
      self:doneHashing(self.hash)
    elseif type(hashed) == 'table' then
      table.insert(self.hashes, hashed)
    end
  until not hashed

  if self.hasherThread:getError() then
    print(self.hasherThread:getError())
  end

  if self.patcherThread then
    repeat
      local response = self.patcherChannel:pop()
      if response then
        -- Crazy zip shit
      end
    until not response
    if self.patcherThread:getError() then
      print(self.patcherThread:getError())
    end
  end
end

function Patcher:doneHashing(hash)
  -- Send to the Hub.
  self.patcherThread = love.thread.newThread('app/thread/patcher.lua')
  self.patcherChannel = love.thread.getChannel('patcher.response')

  self.patcherThread:start(self.hash, json.encode(self.hashes))
end
