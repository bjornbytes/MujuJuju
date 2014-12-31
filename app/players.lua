Players = class()

function Players:init()
  self.players = {}
end

function Players:update()
  table.with(self.players, 'update')
end

function Players:keypressed(...)
  local p = ctx.id and self:get(ctx.id)
  if p then
    p:keypressed(...)
  end
end

function Players:keyreleased(key)
  local p = ctx.id and self:get(ctx.id)
  if p and p.input then
    p.input:keyreleased(key)
  end
end

function Players:mousepressed(x, y, b)
  local p = ctx.id and self:get(ctx.id)
  if p and p.input then
    p.input:mousepressed(x, y, b)
  end
end

function Players:add(id, vars)
  local player = self:get(id)
  if player then return player end
  player = Player()
  player.id = id
  player.team = 1
  table.merge(vars, player)
  f.exe(player.activate, player)
  self.players[id] = player
  return player
end

function Players:remove(id)
  local player = self.players[id]
  if not player then return end
  f.exe(player.deactivate, player)
  self.players[id] = nil
  return player
end

function Players:get(id, t)
  if not id or not self.players[id] then return nil end
  return self.players[id]
end

function Players:each(fn)
  table.each(self.players, function(player, id)
    fn(self:get(id))
  end)
end
