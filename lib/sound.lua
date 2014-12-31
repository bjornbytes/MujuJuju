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

function Sound:play(options)
  local name = options.sound
  if self.muted or not data.media.sounds[name] then return end
  local sound = data.media.sounds[name]:play()
  sound:setVolume(options.volume or 1)
  sound:setRelative(options.relative or false)
  sound:setRolloff(options.rolloff or 1)
  sound:setPosition(options.x or 0, options.y or 0, options.z or 0)
  sound:setAttenuationDistances(options.minrange or 10000, options.maxrange or 10000)
  f.exe(options.with, sound)
  return sound
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
