PlayerBuffs = class()

function PlayerBuffs:init(player)
  self.player = player
  self.list = {}
end

function PlayerBuffs:update()
  table.with(self.list, 'rot')
  table.with(self.list, 'update')
end

function PlayerBuffs:add(code, vars)
  if self:get(code) then return self:reapply(code, vars) end
  local buff = data.buff[code]()
  buff.player = self.player
  self.list[buff] = buff
  table.merge(vars, buff, true)
  f.exe(buff.activate, buff)
  return buff
end

function PlayerBuffs:remove(buff)
  if type(buff) == 'string' then
    buff = self:get(buff)
  end

  if buff then
    f.exe(buff and buff.deactivate, buff, self.player)
    self.list[buff] = nil
  end
end

function PlayerBuffs:get(code)
  return next(table.filter(self.list, function(buff) return buff.code == code end))
end

function PlayerBuffs:reapply(code, vars)
  local buff = self:get(code)
  if buff then
    table.merge(vars, buff, true)
    return buff
  else
    return self:add(code, vars)
  end
end

function PlayerBuffs:buffsWithTag(tag)
  return table.filter(self.list, function(buff) return table.has(buff.tags, tag) end)
end

function PlayerBuffs:prehurt(amount, source, kind)
  table.each(self.list, function(buff)
    if buff.prehurt then
      amount = buff:prehurt(amount, source, kind) or amount
    end
  end)

  return amount
end

function PlayerBuffs:posthurt(amount, source, kind)
  table.with(self.list, 'posthurt', amount, source, kind)

  return amount
end

function PlayerBuffs:die()
  table.with(self.list, 'die')
end
