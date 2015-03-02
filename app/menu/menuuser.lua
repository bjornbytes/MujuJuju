local g = love.graphics

MenuUser = class()

function MenuUser:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    slot1 = function()
      local u, v = ctx.u, ctx.v
      local w = u * .45
      local h = v * .15
      return {u * .5 - w / 2, v * .5 - (h * 1.5), w, h}
    end,

    remove1 = function()
      local slot1 = self.geometry.slot1
      local u, v = ctx.u, ctx.v
      local w = u * .04
      local h = v * .06
      return {slot1[1] + slot1[3] + 5, slot1[2], w, h}
    end,

    slot2 = function()
      local u, v = ctx.u, ctx.v
      local sx, sy, sw, sh = unpack(self.geometry.slot1)
      local w = u * .45
      local h = v * .15
      return {u * .5 - w / 2, sy + sh + 5, w, h}
    end,

    remove2 = function()
      local slot2 = self.geometry.slot2
      local u, v = ctx.u, ctx.v
      local w = u * .04
      local h = v * .06
      return {slot2[1] + slot2[3] + 5, slot2[2], w, h}
    end,

    slot3 = function()
      local u, v = ctx.u, ctx.v
      local sx, sy, sw, sh = unpack(self.geometry.slot2)
      local w = u * .45
      local h = v * .15
      return {u * .5 - w /2, sy + sh + 5, w, h}
    end,

    remove3 = function()
      local slot3 = self.geometry.slot3
      local u, v = ctx.u, ctx.v
      local w = u * .04
      local h = v * .06
      return {slot3[1] + slot3[3] + 5, slot3[2], w, h}
    end
  }

  self.active = false
  self:activate()
end

function MenuUser:activate()
  -- Gather existing user saves
  self.users = {}
  if love.filesystem.exists('save') then
    love.filesystem.getDirectoryItems('save', function(file)
      if love.filesystem.isDirectory('save/' .. file) then
        local file = love.filesystem.read('save/' .. file .. '/user.json')
        local user = json.decode(file)
        self.users[user.slot] = user
      end
    end)
  end

  -- Initialize slots and their states
  self.slots = {}
  self.remove = {}
  for i = 1, 3 do
    self.slots[i] = ctx.gooey:add(Button, 'menu.user.slot' .. i)
    self.slots[i].geometry = function() return self.geometry['slot' .. i] end
    self.slots[i].text = self.users[i] and self.users[i].name or 'Empty Slot'
    self.slots[i].empty = not self.users[i]
    self.slots[i]:on('click', function() self:slotPicked(i) end)

    if self.users[i] then
      self.remove[i] = ctx.gooey:add(Button, 'menu.user.remove' .. i)
      self.remove[i].geometry = function() return self.geometry['remove' .. i] end
      self.remove[i].text = 'X'
      self.remove[i]:on('click', function() self:removeSlot(i) end)
    end
  end
end

function MenuUser:update()
  if not self.active then return end
end

function MenuUser:draw()
  if not self.active then return end

  local u, v = ctx.u, ctx.v

  g.setColor(255, 255, 255)
  g.setFont('mesmerize', v * .05)
  g.printCenter(string.upper('Choose a game slot'), u * .5, v * .18)

  for i = 1, #self.slots do
    self.slots[i]:draw()
    if self.remove[i] then self.remove[i]:draw() end
  end
end

function MenuUser:keypressed(key)
  if key == 'escape' then
    ctx:goto('start')
    return true
  end
end

function MenuUser:resize()
  table.clear(self.geometry)
end

function MenuUser:slotPicked(slot)
  if not self.slots[slot].empty then
    ctx.user = self.users[slot]
    ctx:goto('main')
  else
    ctx.choose.user.slot = slot
    ctx:goto('choose')
  end
end

function MenuUser:removeSlot(slot)
  print(slot, self.slots[slot].empty)
  if not self.slots[slot].empty then
    love.filesystem.remove('save/' .. self.users[slot].name .. '/user.json')
    love.filesystem.remove('save/' .. self.users[slot].name .. '/achievements.json')
    love.filesystem.remove('save/' .. self.users[slot].name)
    ctx:goto('select')
  end
end
