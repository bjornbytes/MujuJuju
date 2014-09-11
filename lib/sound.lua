Sound = class()

function Sound:init()
  self.muted = false
	self.sounds = {}
end

function Sound:play(data)
  if self.muted then return end

  local name = data.sound

	if not self.sounds[name] and love.filesystem.exists('media/sounds/' .. name .. '.ogg') then
		self.sounds[name] = love.audio.newSource('media/sounds/' .. name .. '.ogg')
	end

	if self.sounds[name] then
		local sound = self.sounds[name]:play()
		return sound
	end

	return nil
end

function Sound:loop(data)
  local sound = self:play(data)
  if sound then sound:setLooping(true) end
  return sound
end

function Sound:mute()
  self.muted = not self.muted
  love.audio.tags.all.setVolume(self.muted and 0 or 1)
end
