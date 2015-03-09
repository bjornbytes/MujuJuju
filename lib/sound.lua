Sound = class()

function Sound:init(options)
  options = options or {}

  self.muted = options.muted or false
  self.volumes = {master = options.master or 1.0, music = options.music or 1.0, sound = options.sound or 1.0}
	self.sounds = {}
  self.tags = {sound = setmetatable({}, {__mode = 'kv'}), music = setmetatable({}, {__mode = 'kv'})}
  self.baseVolumes = setmetatable({}, {__mode = 'k'})

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
  self.baseVolumes[sound] = sound:getVolume()
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
    sound:setVolume(self.muted and 0 or self.volumes.master * self.volumes.music * (self.baseVolumes[sound] or 1))
  end)

  table.each(self.tags.sound, function(sound)
    sound:setVolume(self.muted and 0 or self.volumes.master * self.volumes.sound * (self.baseVolumes[sound] or 1))
  end)
end
