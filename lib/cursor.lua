Cursor = class()

function Cursor:init()
  self.cursorDefault = love.mouse.newCursor('media/graphics/cursor.png')
  self.cursorHover = love.mouse.newCursor('media/graphics/cursorHover.png', 3, 2)
end

function Cursor:update()
  love.mouse.setCursor(self.cursorDefault)
end

function Cursor:hover()
  love.mouse.setCursor(self.cursorHover)
end
