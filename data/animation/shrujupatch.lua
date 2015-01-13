local ShrujuPatch = extend(Animation)

ShrujuPatch.scale = 1
ShrujuPatch.default = 'spawn'
ShrujuPatch.states = {}

ShrujuPatch.states.spawn = {
  priority = 1,
  speed = .85
}

ShrujuPatch.states.idle = {
  priority = 1,
  loop = true,
  speed = .06
}

return ShrujuPatch
