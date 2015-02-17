Cursor = class()

function Cursor:init()
  self.hovered = false
  self:resize()
end

function Cursor:update()
  if not self.hovered then love.mouse.setCursor(self.cursorDefault) end
  self.hovered = false
end

function Cursor:hover()
  love.mouse.setCursor(self.cursorHover)
  self.hovered = true
end

function Cursor:resize()
  if love.window.getPixelScale() == 2 then
    self.cursorDefault = love.mouse.newCursor('media/graphics/cursorx2.png')
    self.cursorHover = love.mouse.newCursor('media/graphics/cursorHoverx2.png')
  else
    self.cursorDefault = love.mouse.newCursor('media/graphics/cursor.png')
    self.cursorHover = love.mouse.newCursor('media/graphics/cursorHover.png')
  end
end
