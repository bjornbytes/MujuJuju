Sound = class()

function Sound:init()
  self.mute = false
	self.sounds = {}
end

function Sound:play(data)
  if self.mute then return end
  local name = data.sound
	self.sounds[name] = self.sounds[name] or love.audio.newSource('media/sounds/' .. name .. '.ogg')
  return data.media.sounds[name]:play()
end

function Sound:loop(data)
  local sound = self:play(data)
  if sound then sound:setLooping(true) end
  return sound
end

function Sound:mute()
  self.mute = not self.mute
  love.audio.tag.all.stop()
end
