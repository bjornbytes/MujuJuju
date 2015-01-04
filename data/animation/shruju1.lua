local Shruju = extend(Animation)
Shruju.code = 'shruju1'

Shruju.scale = 1
Shruju.default = 'spawn'
Shruju.states = {}

Shruju.states.spawn = {
  priority = 1,
  speed = .85
}

Shruju.states.idle = {
  priority = 1,
  loop = true,
  speed = .22
}

return Shruju
