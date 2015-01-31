Sound = class()

function Sound:init()
  self.muted = false
	self.sounds = {}

  if ctx.event then
    ctx.event:on('sound.play', f.cur(self.play, self))
    ctx.event:on('sound.loop', f.cur(self.loop, self))
  end
end

function Sound:update()
  love.audio.setPosition(ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2, 200)
end

function Sound:play(sound, cb)
  if self.muted or not sound then return end
  if type(sound) == 'string' then sound = data.media.sounds[sound] end
  if not sound then return end

  local sound = sound:play()
  if sound then f.exe(cb, sound) end
  return sound
end

function Sound:loop(sound, cb)
  return self:play(sound, function(sound)
    sound:setLooping(true)
    f.exe(cb, sound)
  end)
end

function Sound:mute()
  self.muted = not self.muted
  love.audio.tags.all.setVolume(self.muted and 0 or 1)
end

function Sound:setMute(muted)
  if self.muted ~= muted then self:mute() end
end
