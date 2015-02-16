Konami = class()

function Konami:init()
  self.index = 1
  self.states = {'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a', 'return'}
  self.timer = 0
  self.sound = data.media.sounds.laugh
end

function Konami:update()
  self.timer = timer.rot(self.timer, function() self.index = 1 end)
end

function Konami:keypressed(key)
  if key == self.states[self.index] then
    self.index = self.index + 1
    self.timer = .5
    if self.index > #self.states then
      self.index = 1
      self.sound:play()
    end
  end
end
