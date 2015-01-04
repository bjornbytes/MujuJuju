Effects = class()

function Effects:init()
  self.active = love.graphics.isSupported('shader')
  self.effects = {}
	self:add('vignette')
	--self:add('bloom')
	self:add('wave')
	self:add('deathBlur')
end

function Effects:update()
  if not self.active then return end
  for i = 1, #self.effects do f.exe(self.effects[i].update, self.effects[i]) end
end

function Effects:resize()
  if not self.active then return end
  for i = 1, #self.effects do f.exe(self.effects[i].resize, self.effects[i]) end
end

function Effects:add(kind)
  if not self.active then return end
  local effect = new(data.effect[kind])
  f.exe(effect.activate, effect)
  table.insert(self.effects, effect)
  self.effects[kind] = effect
  ctx.event:emit('view.register', {object = effect, mode = 'effect'})
end

function Effects:remove(code)
  self.effects[code] = nil
  for i = #self.effects, 1, -1 do
    if self.effects[i].code == code then
      ctx.event:emit('view.unregister', {object = effect})
      table.remove(self.effects, i)
    end
  end
end

function Effects:get(code)
  return self.effects[code]
end
