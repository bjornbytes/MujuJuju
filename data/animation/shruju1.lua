local Shruju = extend(Animation)
Shruju.code = 'shruju1'

Shruju.scale = 1
Shruju.offsetx = 40
Shruju.offsety = 40
Shruju.default = 'idle'
Shruju.states = {}

Shruju.states.spawn = {
  priority = 1,
  speed = .22
}

Shruju.states.idle = {
  priority = 1,
  loop = true,
  speed = .85
}

return Shruju
