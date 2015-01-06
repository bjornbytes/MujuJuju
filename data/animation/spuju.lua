local Spuju = extend(Animation)
Spuju.code = 'spuju'

Spuju.scale = .75
Spuju.offsety = 32
Spuju.backwards = true
Spuju.default = 'spawn'
Spuju.states = {}

Spuju.states.spawn = {
  priority = 5,
  speed = 1
}

Spuju.states.idle = {
  priority = 1,
  loop = true,
  speed = .25
}

Spuju.states.walk = {
  priority = 1,
  loop = true,
  speed = .25
}

Spuju.states.attack = {
  priority = 1,
  loop = true,
  speed = 1
}

Spuju.states.death = {
  priority = 5,
  speed = .34
}

return Spuju
