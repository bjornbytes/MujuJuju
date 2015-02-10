local g = love.graphics
Tutorial = class()

function Tutorial:init()
  self.messages = {
    'Yo this is Muju',
    'You can stride round the hood with a and d',
  }

  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Tutorial:update()

end

function Tutorial:gui()
  local u, v = ctx.view.frame.width, ctx.view.frame.height
  local font = g.setFont('mesmerize', .06 * v)

  if #self.messages > 0 then
    g.setColor(255, 255, 255)
    g.printShadow(self.messages[1], u * .5, v * .5, true)
  end
end

function Tutorial:keypressed(key)
  if key == ' ' then table.remove(self.messages, 1) end
end
