local g = love.graphics
Checkbox = class()

function Checkbox:draw(x, y, checked)
  if checked then
    g.setColor(100, 200, 50)
    g.circle('fill', x, y, 8, 20)
  end

  g.setColor(255, 255, 255)
  g.setLineWidth(2)
  g.circle('line', x, y, 8, 20)
  g.setLineWidth(1)
end
