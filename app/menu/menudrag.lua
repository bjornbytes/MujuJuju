MenuDrag = class()

function MenuDrag:init()
  self.active = false
end

function MenuDrag:update()
  if self.active then
    --
  end
end

function MenuDrag:draw()
  if self.active then
    --
  end
end

function MenuDrag:mousepressed(mx, my, b)
  if b == 'l' then
    if stuff then
      self.active = true
    end
  end
end

function MenuDrag:mousereleased(mx, my, b)
  -- Drop the base

  self.active = false
end

