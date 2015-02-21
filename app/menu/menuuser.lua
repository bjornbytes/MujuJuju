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

    slot2 = function()
      local u, v = ctx.u, ctx.v
      local sx, sy, sw, sh = unpack(self.geometry.slot1)
      local w = u * .45
      local h = v * .15
      return {u * .5 - w / 2, sy + sh + 5, w, h}
    end,

    slot3 = function()
      local u, v = ctx.u, ctx.v
      local sx, sy, sw, sh = unpack(self.geometry.slot2)
      local w = u * .45
      local h = v * .15
      return {u * .5 - w /2, sy + sh + 5, w, h}
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
  for i = 1, 3 do
    self.slots[i] = ctx.gooey:add(Button, 'menu.user.slot' .. i)
    self.slots[i].geometry = function() return self.geometry['slot' .. i] end
    self.slots[i].text = self.users[i] and self.users[i].name or 'Empty Slot'
    self.slots[i].empty = not self.users[i]
    self.slots[i]:on('click', function() self:slotPicked(i) end)
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
