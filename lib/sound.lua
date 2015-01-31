Sound = class()

function Sound:init()
  self.muted = false
  self.volumes = {master = 1.0, music = 1.0, sound = 1.0}
	self.sounds = {}
  self.tags = {sound = setmetatable({}, {__mode = 'kv'}), music = setmetatable({}, {__mode = 'kv'})}

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

  local isMusic = self:isMusic(sound)

  local sound = sound:play()
  if sound then f.exe(cb, sound) end
  local tag = isMusic and 'music' or 'sound'
  self.tags[tag] = self.tags[tag] or {}
  self.tags[tag][sound] = sound
  self:refreshVolumes()
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
  self:refreshVolumes()
end

function Sound:setMute(muted)
  if self.muted ~= muted then self:mute() end
end

function Sound:isMusic(sound)
  return sound == data.media.sounds.riteOfPassage or sound == data.media.sounds.background
end

function Sound:refreshVolumes()
  table.each(self.tags.music, function(sound)
    sound:setVolume(self.muted and 0 or self.volumes.master * self.volumes.music)
  end)

  table.each(self.tags.sound, function(sound)
    sound:setVolume(self.muted and 0 or self.volumes.master * self.volumes.sound)
  end)
end
